{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
let
  services = [
    "sonarr.service"
    "radarr.service"
    "prowlarr.service"
    "bazarr.service"
  ];
in
{
  imports = [
    inputs.nixarr.nixosModules.default
  ];

  nixarr = {
    enable = true;
    # These two values are also the default, but you can set them to whatever
    # else you want
    # WARNING: Do _not_ set them to `/home/user/whatever`, it will not work!
    mediaDir = "/data/media";
    stateDir = "/data/media/.state/nixarr";

    vpn = {
      enable = false;
      # WARNING: This file must _not_ be in the config git directory
      # You can usually get this wireguard file from your VPN provider
      wgConf = "/data/.secret/wg.conf";
    };

    jellyfin = {
      enable = true;
      # These options set up a nginx HTTPS reverse proxy, so you can access
      # Jellyfin on your domain with HTTPS
      expose.https = {
        enable = false;
        domainName = "your.domain.com";
        acmeMail = "your@email.com"; # Required for ACME-bot
      };
    };

    transmission = {
      enable = true;
      vpn.enable = false;
      peerPort = 50000; # Set this to the port forwarded by your VPN
    };

    # It is possible for this module to run the *Arrs through a VPN, but it
    # is generally not recommended, as it can cause rate-limiting issues.
    bazarr.enable = true;
    lidarr.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    readarr.enable = true;
    sonarr.enable = true;
    jellyseerr.enable = true;
  };

  services.flaresolverr = {
    enable = true;
    openFirewall = true;
    port = 8191;
  };

  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME =
    "${config.environment.sessionVariables.LIBVA_DRIVER_NAME}"; # Set the environment variable for the service

  services.caddy = {
    virtualHosts = {
      "jellyfin.${config.sensitive.myDomain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8096
        '';
      };
      "bazarr.${config.sensitive.myDomain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.services.bazarr.listenPort}
        '';
      };
      "lidarr.${config.sensitive.myDomain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.services.lidarr.settings.server.port}
        '';
      };
      "prowlarr.${config.sensitive.myDomain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.services.prowlarr.settings.server.port}
        '';
      };
      "radarr.${config.sensitive.myDomain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.services.radarr.settings.server.port}
        '';
      };
      "sonarr.${config.sensitive.myDomain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.services.sonarr.settings.server.port}
        '';
      };
      "jellyseerr.${config.sensitive.myDomain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.services.jellyseerr.port}
        '';
      };
      "readarr.${config.sensitive.myDomain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.services.readarr.settings.server.port}
        '';
      };
    };
  };

  services.restic.backups = lib.genAttrs [ "local" "hetzner" ] (_: {
    paths = [
      # config.nixarr.mediaDir # Uncomment to backup media files
      config.nixarr.stateDir # Nixarr configuration and database files for all *arr services
    ];

    exclude = [
      # Exclude cache and temporary files
      "${config.nixarr.stateDir}/**/cache/**"
      "${config.nixarr.stateDir}/**/logs/**"
      "${config.nixarr.stateDir}/**/tmp/**"
      # Exclude large media processing temporary files
      "${config.nixarr.stateDir}/**/MediaCover/**"
      "**/.DS_Store"
      "**/Thumbs.db"
    ];
  });

  # Configure restic backups to stop Nixarr services while running
  systemd.services = lib.genAttrs [ "restic-backups-local" "restic-backups-hetzner" ] (_: {
    unitConfig = {
      Conflicts = services;
      After = services;
      OnFailure = services;
      OnSuccess = services;
    };
  });
}
