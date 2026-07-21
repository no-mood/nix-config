{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  options.custom.backupSources = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          paths = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Paths to include in backups.";
          };
          excludes = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Patterns to exclude from backups.";
          };
          prepareCommands = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Commands to run before backup starts.";
          };
          cleanupCommands = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Commands to run after backup completes.";
          };
        };
      }
    );
    default = { };
    description = "Backup sources aggregated by restic-client.";
  };

  config =
    let
      commonExcludes = [
        # Caches
        "**/cache/**"
        "**/.cache/**"
        "**/Cache/**"
        "**/.tmp/**"
        "*.tmp"
        "*.log"
        # Dev artifacts (regenerable)
        "**/.devenv/**"
        "**/.direnv/**"
        "**/result"
        "**/result-*"
        # Build outputs
        "**/node_modules/**"
        "**/target/**"
        "**/dist/**"
        "**/build/**"
        # Python/virtualenvs
        "**/.venv/**"
        "**/__pycache__/**"
      ];

      # Wrapper scripts that run as the restic system user.
      # They read secrets directly (restic owns them) via file-based env vars.
      resticLocalScript = pkgs.writeShellScript "restic-local" ''
        set -a
        . ${config.sops.templates."restic-env-local".path}
        set +a
        RESTIC_PASSWORD_FILE=${config.sops.secrets."restic/local/password".path} \
        RESTIC_REPOSITORY="rest:https://restic.${config.sensitive.myDomain}/${config.networking.hostName}" \
        exec ${lib.getExe pkgs.restic} "$@"
      '';

      resticHetznerScript = pkgs.writeShellScript "restic-hetzner" ''
        RESTIC_PASSWORD_FILE=${config.sops.secrets."restic/hetzner/password".path} \
        RESTIC_REPOSITORY_FILE=${config.sops.secrets."restic/hetzner/repository".path} \
        exec ${lib.getExe pkgs.restic} \
          -o "sftp.args=-i ${
            config.sops.secrets."restic/hetzner/ssh-key".path
          } -P 23 -o StrictHostKeyChecking=accept-new -o BatchMode=yes" \
          "$@"
      '';
    in
    {
      environment.systemPackages = [ pkgs.restic ];

      environment.shellAliases = {
        restic-local = "sudo -u restic ${resticLocalScript}";
        restic-hetzner = "sudo -u restic ${resticHetznerScript}";
      };

      # Dedicated restic user with capability to read all files without running as root: https://wiki.nixos.org/wiki/Restic#Security_Wrapper
      users.users.restic = {
        group = "restic";
        isSystemUser = true;
      };
      users.groups.restic = { };

      security.wrappers.restic = {
        source = lib.getExe pkgs.restic;
        owner = "restic";
        group = "restic";
        permissions = "500";
        capabilities = "cap_dac_read_search+ep";
      };

      # Allow restic system user to take sleep inhibitor locks via logind
      # Required for inhibitsSleep = true, which uses systemd-inhibit --what=sleep under the hood, if using the security wrapper
      security.polkit.extraConfig = ''
            polkit.addRule(function(action, subject) {
              if (action.id === "org.freedesktop.login1.inhibit-block-sleep" &&
                  subject.user === "restic") {
                return polkit.Result.YES;
              }
            });
        polkit.addRule(function(action, subject) {
          if (action.id === "org.freedesktop.systemd1.manage-units" &&
              (action.lookup("verb") === "start" || action.lookup("verb") === "stop") &&
              subject.user === "restic") {
            return polkit.Result.YES;
          }
        });
      '';

      # Host backup configuration (system + home)
      services.restic.backups = {
        local = {
          initialize = true;
          inhibitsSleep = true;

          user = "restic";
          package = pkgs.writeShellScriptBin "restic" ''exec /run/wrappers/bin/restic "$@"'';

          repository = "rest:https://restic.${config.sensitive.myDomain}/${config.networking.hostName}";
          passwordFile = config.sops.secrets."restic/local/password".path; # Encryption key
          environmentFile = config.sops.templates."restic-env-local".path;

          paths = lib.concatLists (lib.mapAttrsToList (_: src: src.paths) config.custom.backupSources);
          exclude =
            commonExcludes
            ++ lib.concatLists (lib.mapAttrsToList (_: src: src.excludes) config.custom.backupSources);

          backupPrepareCommand = lib.concatStringsSep "\n" (
            [ "echo '=== Restic Backup Preparation Started ==='" ]
            ++ lib.concatLists (lib.mapAttrsToList (_: src: src.prepareCommands) config.custom.backupSources)
            ++ [ "echo '=== Backup Preparation Complete ==='" ]
          );

          backupCleanupCommand = lib.concatStringsSep "\n" (
            [ "echo '=== Restic Backup Cleanup Started ==='" ]
            ++ lib.concatLists (lib.mapAttrsToList (_: src: src.cleanupCommands) config.custom.backupSources)
            ++ [ "echo '=== Backup Cleanup Complete ==='" ]
          );

          timerConfig = {
            OnCalendar = [
              "01:00"
              "daily"
            ];
            Persistent = true;
          };

          # Keep backups for
          pruneOpts = [
            "--keep-daily 7"
            "--keep-weekly 5"
            "--keep-monthly 12"
            "--keep-yearly 10"
          ];
        };

        hetzner = {
          initialize = true;
          inhibitsSleep = true;

          user = "restic";
          package = pkgs.writeShellScriptBin "restic" ''exec /run/wrappers/bin/restic "$@"'';

          # Unique repository but different subaccounts per host
          # Manage through https://console.hetzner.com/
          repositoryFile = config.sops.secrets."restic/hetzner/repository".path;
          passwordFile = config.sops.secrets."restic/hetzner/password".path;

          extraOptions = [
            "sftp.args='-i ${
              config.sops.secrets."restic/hetzner/ssh-key".path
            } -P 23 -o StrictHostKeyChecking=accept-new -o BatchMode=yes'"
          ];

          paths = lib.concatLists (lib.mapAttrsToList (_: src: src.paths) config.custom.backupSources);
          exclude =
            commonExcludes
            ++ lib.concatLists (lib.mapAttrsToList (_: src: src.excludes) config.custom.backupSources);

          backupPrepareCommand = lib.concatStringsSep "\n" (
            [ "echo '=== Restic Backup Preparation Started ==='" ]
            ++ lib.concatLists (lib.mapAttrsToList (_: src: src.prepareCommands) config.custom.backupSources)
            ++ [ "echo '=== Backup Preparation Complete ==='" ]
          );

          backupCleanupCommand = lib.concatStringsSep "\n" (
            [ "echo '=== Restic Backup Cleanup Started ==='" ]
            ++ lib.concatLists (lib.mapAttrsToList (_: src: src.cleanupCommands) config.custom.backupSources)
            ++ [ "echo '=== Backup Cleanup Complete ==='" ]
          );

          timerConfig = {
            OnCalendar = [
              "02:00"
              "daily"
            ];
            Persistent = true;
          };

          pruneOpts = [
            "--keep-daily 7"
            "--keep-weekly 5"
            "--keep-monthly 12"
            "--keep-yearly 10"
          ];
        };
      };

      sops = {
        secrets = {
          # Sops configuration for restic password and REST credentials
          "restic/local/password" = {
            owner = "restic";
            restartUnits = [ "restic-backups-local.service" ];
          };

          "restic/local/rest-username" = {
            owner = "restic";
            restartUnits = [ "restic-backups-local.service" ];
          };

          "restic/local/rest-password" = {
            owner = "restic";
            restartUnits = [ "restic-backups-local.service" ];
          };

          # Sops configuration for Hetzner Storage Box backup
          "restic/hetzner/repository" = {
            sopsFile = inputs.self.outPath + "/nixos/hosts/${config.networking.hostName}/secrets.yaml";
            owner = "restic";
            restartUnits = [ "restic-backups-hetzner.service" ];
          };

          "restic/hetzner/password" = {
            sopsFile = inputs.self.outPath + "/nixos/hosts/${config.networking.hostName}/secrets.yaml";
            owner = "restic";
            restartUnits = [ "restic-backups-hetzner.service" ];
          };

          "restic/hetzner/ssh-key" = {
            sopsFile = inputs.self.outPath + "/nixos/hosts/${config.networking.hostName}/secrets.yaml";
            owner = "restic";
            mode = "0400";
            restartUnits = [ "restic-backups-hetzner.service" ];
          };
        };
        # Template for local environment variables
        templates."restic-env-local" = {
          owner = "restic";
          content = ''
            RESTIC_REST_USERNAME=${config.sops.placeholder."restic/local/rest-username"}
            RESTIC_REST_PASSWORD=${config.sops.placeholder."restic/local/rest-password"}
          '';
          restartUnits = [ "restic-backups-local.service" ];
        };
      };

      # Prevent concurrent backups via mutual conflicts
      systemd.services = lib.mapAttrs' (
        backupName: _:
        let
          serviceName = "restic-backups-${backupName}";
          # Generate conflicts with all other backup services
          otherBackups = lib.filter (n: n != backupName) (lib.attrNames config.services.restic.backups);
          conflictServices = map (n: "restic-backups-${n}.service") otherBackups;
        in
        lib.nameValuePair serviceName {
          serviceConfig.TimeoutStartSec = "infinity"; # Allow unlimited time for backup preparation and completion
          conflicts = conflictServices;
        }
      ) config.services.restic.backups;
    };
}
