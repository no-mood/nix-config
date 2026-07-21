{
  pkgs,
  config,
  lib,
  ...
}:
let
  tailscaleAddr = config.networking.tailscaleAddress;
  credsTemplate = config.sops.templates.factorio.path;
  containerRoot = "/var/lib/nixos-containers/factorio";

  modListJson = pkgs.writeText "mod-list.json" (
    builtins.toJSON {
      mods = [
        {
          name = "base";
          enabled = true;
        }
        {
          name = "elevated-rails";
          enabled = false;
        }
        {
          name = "quality";
          enabled = false;
        }
        {
          name = "space-age";
          enabled = false;
        }
      ];
    }
  );
in
{
  sops.secrets = {
    "factorio/username" = {
      # sopsFile = ../secrets/ssl-proxy/factorio.yaml;
      restartUnits = [ "container@factorio.service" ];
    };
    "factorio/game_password" = {
      # sopsFile = ../secrets/ssl-proxy/factorio.yaml;
      restartUnits = [ "container@factorio.service" ];
    };
    "factorio/token" = {
      # sopsFile = ../secrets/ssl-proxy/factorio.yaml;
      restartUnits = [ "container@factorio.service" ];
    };
  };
  sops.templates.factorio.content = ''
    {
      "username" : "${config.sops.placeholder."factorio/username"}",
      "game_password":"${config.sops.placeholder."factorio/game_password"}",
      "token":"${config.sops.placeholder."factorio/token"}"
    }
  '';

  containers.factorio = {
    autoStart = false;
    bindMounts."${credsTemplate}".isReadOnly = true;
    config =
      {
        lib,
        pkgs,
        config,
        ...
      }:
      {
        services.factorio = {
          enable = true;
          openFirewall = true;
          package = pkgs.factorio-headless-experimental;
          stateDirName = "factorio"; # hardcoded under /var/lib
          description = "My Factorio server";
          requireUserVerification = false;
          public = false;
          lan = true;
          bind = tailscaleAddr; # host's tailscale address, captured via closure
          port = 34197;
          nonBlockingSaving = true;
          autosave-interval = 10;
          admins = [ "xmood" ];
          extraSettingsFile = "/run/credentials/factorio.service/factorio.json";
        };

        # Give systemd the credentials file under a predictable name.
        systemd.services.factorio.serviceConfig = {
          LoadCredential = "factorio.json:${credsTemplate}";
          RestartSec = 10; # Service tends to fail when system is booting up, this gives it time to try again once network is online
        };

        # TODO set a reverse-proxy for factorio: https://github.com/mholt/caddy-l4

        # Write the mod list after the server starts.
        systemd.services.factorio.postStart = ''
          cat ${modListJson} > /var/lib/${config.services.factorio.stateDirName}/mods/mod-list.json
        '';

        system.stateVersion = "26.05";
      };
  };

  custom.backupSources.factorio = {
    paths = [ "${containerRoot}/var/lib/factorio" ];
    excludes = [
      "${containerRoot}/var/lib/factorio/log/**"
      "${containerRoot}/var/lib/factorio/temp/**"
    ];
    prepareCommands = [ "${lib.getExe pkgs.nixos-container} stop factorio || true" ];
    cleanupCommands = [ "${lib.getExe pkgs.nixos-container} start factorio || true" ];
  };
}
