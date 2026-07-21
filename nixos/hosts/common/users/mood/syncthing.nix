{
  inputs,
  config,
  lib,
  ...
}:
let
  user = "mood";

  # Common folder configuration
  commonFolderConfig = {
    devices = [
      "tau"
      "dra"
      "lyr"
    ];
    ignorePerms = false;
    # Exclude build artifacts, caches, and generated files from all synced folders
    # Pattern format: https://docs.syncthing.net/users/ignoring.html
    ignorePatterns = [
      "(?d).devenv"
      # Common build outputs
      "(?d)result"
      "(?d)result-*"
      "(?d)target"
      "(?d)dist"
      "(?d)build"
      "(?d).direnv"
      # Node/Python caches
      "(?d)node_modules"
      "(?d).venv"
      "(?d)__pycache__"
    ];
  };

  # Directories to sync with common configuration
  syncDirs = [
    "Projects"
    "Documents"
    "Music"
    "Pictures"
    "Public"
    "Templates"
    "Videos"
  ];

  # Generate folder configurations using the mapping
  folders = lib.listToAttrs (
    map (dir: {
      name = dir;
      value = commonFolderConfig // {
        path = "/home/${user}/${dir}";
      };
    }) syncDirs
  );
in
{
  # Syncthing with Declarative Node IDs - User-specific service
  #
  # Each host needs unique key.pem and cert.pem for stable Device ID.
  # Generate them with:
  #   syncthing generate --home /tmp/syncthing-config/$hostname/
  #   cat /tmp/syncthing-config/$hostname/key.pem   # Add to nixos/hosts/$hostname/secrets.yaml under syncthing/key
  #   cat /tmp/syncthing-config/$hostname/cert.pem  # Add to nixos/hosts/$hostname/secrets.yaml under syncthing/cert
  #
  # Per-host secrets structure in nixos/hosts/$hostname/secrets.yaml:
  # syncthing:
  #   guiPassword: "your-password"
  #   key: |
  #     -----BEGIN PRIVATE KEY-----
  #     (content from key.pem)
  #     -----END PRIVATE KEY-----
  #   cert: |
  #     -----BEGIN CERTIFICATE-----
  #     (content from cert.pem)
  #     -----END CERTIFICATE-----

  # Configure sops secrets for Syncthing declarative node IDs
  sops.secrets = {
    "syncthing/guiPassword" = {
      sopsFile = inputs.self.outPath + "/nixos/hosts/common/secrets.yaml";
      owner = user;
      group = "users";
      mode = "0400";
      restartUnits = [ "syncthing.service" ];
    };
    "syncthing/key" = {
      sopsFile = inputs.self.outPath + "/nixos/hosts/${config.networking.hostName}/secrets.yaml";
      owner = user;
      group = "users";
      mode = "0400";
      restartUnits = [ "syncthing.service" ];
    };
    "syncthing/cert" = {
      sopsFile = inputs.self.outPath + "/nixos/hosts/${config.networking.hostName}/secrets.yaml";
      owner = user;
      group = "users";
      mode = "0400";
      restartUnits = [ "syncthing.service" ];
    };
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;

    # Run as mood user to access home directories
    user = user;
    group = "users";
    dataDir = "/home/${user}";

    # GUI configuration
    guiAddress = "127.0.0.1:8384";
    guiPasswordFile = config.sops.secrets."syncthing/guiPassword".path;

    # Use generated certificates for stable Device ID
    key = config.sops.secrets."syncthing/key".path;
    cert = config.sops.secrets."syncthing/cert".path;

    # Declarative configuration
    settings = {
      options.urAccepted = -1;
      # Configure your devices here:
      devices = {
        "tau" = {
          id = config.sensitive.syncthingDevices.tau;
        };
        "dra" = {
          id = config.sensitive.syncthingDevices.dra;
        };
        "lyr" = {
          id = config.sensitive.syncthingDevices.lyr;
        };
      };

      # Syncthing folder configuration for user mood
      folders = folders;
    };
  };

  # Caddy reverse proxy for Syncthing GUI
  services.caddy = {
    virtualHosts = {
      "syncthing.localhost".extraConfig = ''
        reverse_proxy ${config.services.syncthing.guiAddress}
      '';
    };
  };

  # Exclude Syncthing folders from Restic backups on non-lyr hosts
  # (lyr is the single source of truth for offsite backups)
  custom.backupSources.syncthing-exclusions = lib.mkIf (config.networking.hostName != "lyr") {
    excludes = map (folder: "${folder.path}/") (
      lib.attrValues config.services.syncthing.settings.folders
    );
  };
}
