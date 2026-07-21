{
  lib,
  config,
  pkgs,
  ...
}:
let
  containerRoot = "/var/lib/nixos-containers/calibre";
in
{
  containers.calibre = {
    autoStart = true;
    config =
      {
        lib,
        config,
        pkgs,
        ...
      }:
      {
        services.calibre-server = {
          enable = true;
          host = "127.0.0.1";
          port = 8082;
          openFirewall = true;
          user = "calibre-server";
          group = "calibre-server";
          auth.enable = false;
        };

        services.calibre-web = {
          enable = true;
          listen = {
            ip = "127.0.0.1";
            port = 8083;
          };
          openFirewall = true;
          user = "calibre-web";
          group = "calibre-web";
          options = {
            calibreLibrary = builtins.head config.services.calibre-server.libraries;
            enableBookUploading = true;
            enableBookConversion = true;
            enableKepubify = true;
            reverseProxyAuth.enable = false;
          };
        };

        # Add calibre-web to the calibre-server group
        users.users."${config.services.calibre-web.user}".extraGroups = [ "calibre-server" ];

        # Initialize calibre library (metadata.db) if not present yet.
        # This runs `calibredb --with-library <libraryPath> list` which creates the metadata.db if it doesn't exist, without adding any books.
        systemd.services.calibre-server.preStart = lib.concatMapStringsSep "\n" (libPath: ''
          if [ ! -f ${lib.escapeShellArg libPath}/metadata.db ]; then
            ${pkgs.calibre}/bin/calibredb --with-library ${lib.escapeShellArg libPath} list > /dev/null 2>&1 || true
          fi
          chmod g+w ${lib.escapeShellArg libPath}/metadata.db 2>/dev/null || true
        '') config.services.calibre-server.libraries;

        # Ensure the directory exists and has the correct permissions
        # https://www.freedesktop.org/software/systemd/man/tmpfiles.d#Type
        systemd.tmpfiles.settings =
          let
            libraries = config.services.calibre-server.libraries;
          in
          {
            calibre = builtins.listToAttrs (
              map (libPath: {
                name = libPath;
                value = {
                  d = {
                    user = config.services.calibre-server.user;
                    group = config.services.calibre-server.group;
                    mode = "0770"; # rwxrwx---
                  };
                };
              }) libraries
            );
          };

        system.stateVersion = "26.05";
      };
  };

  services.caddy.virtualHosts."calibre-web.${config.sensitive.myDomain}".extraConfig = ''
    reverse_proxy 127.0.0.1:8083
  '';

  custom.backupSources.calibre = {
    paths = [ "${containerRoot}/var/lib/calibre-server" ];
    excludes = [
      # Exclude temporary and cache files
      "${containerRoot}/var/lib/calibre-server/**/.caltrash/**"
      "${containerRoot}/var/lib/calibre-server/**/metadata_db_prefs_backup.json.*"
      "${containerRoot}/var/lib/calibre-server/**/.DS_Store"
      "${containerRoot}/var/lib/calibre-server/**/Thumbs.db"
    ];
    prepareCommands = [ "${lib.getExe pkgs.nixos-container} stop calibre || true" ];
    cleanupCommands = [ "${lib.getExe pkgs.nixos-container} start calibre || true" ];
  };
}
