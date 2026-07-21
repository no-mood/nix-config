{
  config,
  lib,
  pkgs,
  ...
}:
let
  minifluxPort = 8180;
  containerRoot = "/var/lib/nixos-containers/miniflux";
  credsFile = config.sops.templates.miniflux.path;
in
{
  sops = {
    templates.miniflux.content = ''
      ADMIN_USERNAME="${config.sops.placeholder."miniflux/admin_username"}"
      ADMIN_PASSWORD="${config.sops.placeholder."miniflux/admin_password"}"
    '';
    secrets = {
      "miniflux/admin_username" = {
        # sopsFile = ../secrets.yaml;
        restartUnits = [ "container@miniflux.service" ];
      };
      "miniflux/admin_password" = {
        # sopsFile = ../secrets.yaml;
        restartUnits = [ "container@miniflux.service" ];
      };
    };
  };

  containers.miniflux = {
    autoStart = true;
    bindMounts."${credsFile}".isReadOnly = true;
    config =
      { ... }:
      {
        services.miniflux = {
          enable = true;
          createDatabaseLocally = true;
          config.LISTEN_ADDR = "127.0.0.1:${toString minifluxPort}"; # https://miniflux.app/docs/configuration.html
          adminCredentialsFile = credsFile;
        };
        system.stateVersion = "26.05";
      };
  };

  services.caddy.virtualHosts."miniflux.${config.sensitive.myDomain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString minifluxPort}
  '';

  custom.backupSources.miniflux = {
    paths = [ "${containerRoot}/var/lib/postgresql" ];
    prepareCommands = [ "${lib.getExe pkgs.nixos-container} stop miniflux || true" ];
    cleanupCommands = [ "${lib.getExe pkgs.nixos-container} start miniflux || true" ];
  };
}
