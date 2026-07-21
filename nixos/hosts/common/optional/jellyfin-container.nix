{
  accelerationDevices ? [ ],
  ...
}:
{
  lib,
  config,
  ...
}:
let
  containerRoot = "/var/lib/nixos-containers/jellyfin";
  hostHardwareGraphics = config.hardware.graphics;
  hostLibvaDriverName = config.environment.sessionVariables.LIBVA_DRIVER_NAME or null;
in
{
  containers.jellyfin = {
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
      { lib, pkgs, ... }:
      {
        hardware.graphics = hostHardwareGraphics;
        environment.systemPackages = with pkgs; [
          jellyfin
          jellyfin-web
          jellyfin-ffmpeg
        ];
        services.jellyfin = {
          enable = true;
          openFirewall = true;
        };
        systemd.services.jellyfin.environment = lib.optionalAttrs (hostLibvaDriverName != null) {
          LIBVA_DRIVER_NAME = hostLibvaDriverName;
        };
        system.stateVersion = "26.05";
      };
  };

  # Caddy handles the SSL termination and reverse proxying
  # so the port used is the HTTP port, set in the web UI
  services.caddy.virtualHosts."jellyfin.${config.sensitive.myDomain}".extraConfig = ''
    reverse_proxy 127.0.0.1:8096
  '';

  custom.backupSources.jellyfin = {
    paths = [
      "${containerRoot}/var/lib/jellyfin" # Jellyfin database, metadata, and configuration
    ];
    excludes = [
      # Exclude cache and log directories (they can be regenerated)
      "${containerRoot}/var/lib/jellyfin/cache/**"
      "${containerRoot}/var/lib/jellyfin/log/**"
    ];
    prepareCommands = [ "${lib.getExe pkgs.nixos-container} stop jellyfin || true" ];
    cleanupCommands = [ "${lib.getExe pkgs.nixos-container} start jellyfin || true" ];
  };
}
