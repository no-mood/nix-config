{
  accelerationDevices ? [ ],
  ...
}:
{
  pkgs,
  config,
  lib,
  ...
}:
let
  port = 2283;
  mediaLocation = "/var/lib/immich";
  containerRoot = "/var/lib/nixos-containers/immich";
  hostHardwareGraphics = config.hardware.graphics;
in
{
  containers.immich = {
    autoStart = true;
    allowedDevices = map (dev: {
      node = dev;
      modifier = "rw";
    }) accelerationDevices;
    bindMounts = builtins.listToAttrs (
      map (dev: {
        name = dev;
        value = {
          hostPath = dev;
          isReadOnly = false;
        };
      }) accelerationDevices
    );
    config =
      { config, lib, ... }:
      {
        hardware.graphics = hostHardwareGraphics;
        services.immich = {
          enable = true;
          host = "127.0.0.1";
          inherit port mediaLocation;
          machine-learning.enable = true;
          accelerationDevices = accelerationDevices;
          openFirewall = true;
        };

        users.users."${config.services.immich.user}".extraGroups = [
          "video"
          "render"
        ];

        system.stateVersion = "26.05";
      };
  };

  services.caddy.virtualHosts."immich.${config.sensitive.myDomain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString port}
  '';

  # https://docs.immich.app/administration/backup-and-restore/
  custom.backupSources.immich = {
    paths = [
      # Critical: original assets (not reproducible)
      "${containerRoot}${mediaLocation}/library" # original assets — Storage Template ON
      "${containerRoot}${mediaLocation}/upload" # original assets — Storage Template OFF (default since v1.92)
      "${containerRoot}${mediaLocation}/profile" # user profile images
      # DB dumps from Immich's built-in backup — enables in-app restore UI
      "${containerRoot}${mediaLocation}/backups"
    ];
    prepareCommands = [ "${lib.getExe pkgs.nixos-container} stop immich || true" ];
    cleanupCommands = [ "${lib.getExe pkgs.nixos-container} start immich || true" ];
  };
}
