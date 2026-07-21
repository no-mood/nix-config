{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  domain = config.sensitive.myDomain;
  lilyPort = 25565;
  containerRoot = "/var/lib/nixos-containers/minecraft";
in
{
  containers.minecraft = {
    autoStart = false;
    config =
      {
        lib,
        pkgs,
        config,
        ...
      }:
      {
        imports = [ inputs.nix-minecraft.nixosModules.minecraft-servers ];
        nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];
        nixpkgs.config.allowUnfree = true;

        environment.systemPackages =
          lib.optionals config.services.minecraft-servers.managementSystem.tmux.enable
            [ pkgs.tmux ];

        services.minecraft-servers = {
          enable = true;
          dataDir = "/srv/minecraft";
          openFirewall = true;
          eula = true;
          managementSystem = {
            tmux.enable = true;
            systemd-socket.enable = false;
          };
          servers.lily = {
            enable = true;
            autoStart = true;
            enableReload = false;
            serverProperties = {
              enable-jmx-monitoring = false;
              "rcon.port" = 25575;
              level-seed = "1899609589248894497";
              gamemode = "survival";
              enable-command-block = false;
              enable-query = false;
              generator-settings = "{}";
              enforce-secure-profile = true;
              level-name = "world";
              motd = "Mood's Minecraft Server: Lily";
              "query.port" = lilyPort;
              pvp = true;
              generate-structures = true;
              max-chained-neighbor-updates = 1000000;
              difficulty = "hard";
              network-compression-threshold = 256;
              max-tick-time = 60000;
              require-resource-pack = false;
              use-native-transport = true;
              max-players = builtins.length (
                builtins.attrValues config.services.minecraft-servers.servers.lily.whitelist
              );
              online-mode = true;
              enable-status = true;
              allow-flight = true;
              initial-disabled-packs = "";
              broadcast-rcon-to-ops = true;
              view-distance = 20;
              server-ip = "";
              resource-pack-prompt = "";
              allow-nether = true;
              server-port = lilyPort;
              enable-rcon = false;
              sync-chunk-writes = true;
              op-permission-level = 4;
              prevent-proxy-connections = false;
              hide-online-players = false;
              resource-pack = "";
              entity-broadcast-range-percentage = 100;
              simulation-distance = 10;
              "rcon.password" = "";
              player-idle-timeout = 0;
              force-gamemode = false;
              rate-limit = 0;
              hardcore = false;
              white-list = true;
              broadcast-console-to-ops = true;
              spawn-npcs = true;
              spawn-animals = true;
              log-ips = true;
              function-permission-level = 2;
              initial-enabled-packs = "vanilla";
              level-type = "minecraft:\normal";
              text-filtering-config = "";
              spawn-monsters = true;
              enforce-whitelist = true;
              spawn-protection = 16;
              resource-pack-sha1 = "";
              max-world-size = 29999984;
            };
            whitelist = {
              xM00D = "1b28c008-b6fd-42ee-adc3-0baab4921966";
              xM00Dx = "e2a4f76c-f89a-4054-aa9c-c609fac8658a";
            };
            operators = { };
            # Specify the custom minecraft server package
            package = pkgs.fabricServers.fabric-1_21_4.override {
              loaderVersion = "0.16.10";
            }; # Specific fabric loader version
            jvmOpts = "-Xmx4G -Xms4G";
            # XXX "files" was previously "symlinks", but this makes the mods directory read-only, and some plugins require write access for their configuration files (like LuckPerms).
            # Since they will be deleted after the server stops, any modification is discarded.
            # This is useful to determine if a plugin would require write access to the mods directory
            files = {
              mods = pkgs.linkFarmFromDrvs "mods" (
                builtins.attrValues {
                  Fabric-API = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/bQZpGIz0/fabric-api-0.119.2%2B1.21.4.jar";
                    hash = "sha512-u43pDV0RZezBemIOwkzmlG9Xjh2DTdxJ+FwoFqDDupVOw35k9iWi9JbTWsHbhbSV+XikAqYrv8xWF5XeMJi1yQ==";
                  };
                  NoChatReports = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/9xt05630/NoChatReports-FABRIC-1.21.4-v2.11.0.jar";
                    hash = "sha256-1jMJbw5wL/PwsNSEHs4MHJpjyvPVhbhiP59dnXRQJwI=";
                  };
                  DistantHorizons = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/uCdwusMi/versions/DTFSZmMF/DistantHorizons-neoforge-fabric-2.3.0-b-1.21.4.jar";
                    hash = "sha256-FqV3dvw8VD4DM+b7cP49/zeh2jUtyQmkDtodQQLt948=";
                  };
                  LuckPerms = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/Vebnzrzj/versions/6h9SnsZu/LuckPerms-Fabric-5.4.150.jar";
                    hash = "sha256-nP/5jzU+v5/kAAsohmGlfNuvo56ms4XMznGotfhXQPQ=";
                  };
                  fabric-essentials = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/o69N0FT2/versions/c3eNaHSt/fabric-essentials-1.4.0%2B1.21.4.jar";
                    hash = "sha256-Mj3AYzZaEG7Nw3mzXAuFqXqNq3kUl8EkD/pbRLV072c=";
                  };
                  worldedit = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/1u6JkXh5/versions/KI46lJsd/worldedit-mod-7.3.10.jar";
                    hash = "sha256-0n6eJRFaA4DNnVofv2fK06vpyyhNH2wAyArhh+/fD6k=";
                  };
                  colletive = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/e0M1UDsY/versions/SmRj4qMG/collective-1.21.4-7.94.jar";
                    hash = "sha256-o5FJjhNwDbT7cEhFxL7H1zA27/pHZZixOzb+VD9vAtc=";
                  };
                  youritemsaresafe = pkgs.fetchurl {
                    url = "https://cdn.modrinth.com/data/lL35xmSR/versions/AJ2ZMqRz/youritemsaresafe-1.21.4-4.7.jar";
                    hash = "sha256-YjSv5LYm2ZKht73QoaSoDuPLd1OXZkGZNHwtauOF/nE=";
                  };
                }
              );
            };
            symlinks = {
              "server-icon.png" = ./lily_server-icon.png; # TODO find a better place for this
            };
          };
        };

        system.stateVersion = "26.05";
      };
  };

  # Caddy on the host reverse-proxies into the container (shared network namespace).
  services.caddy.virtualHosts."minecraft-lily.${domain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString lilyPort}
  '';

  # Restic: active only when restic-client.nix is imported (sets security.wrappers.restic).
  custom.backupSources.minecraft = {
    paths = [ "${containerRoot}/srv/minecraft" ];
    excludes = [
      "${containerRoot}/srv/minecraft/*/logs/**"
      "${containerRoot}/srv/minecraft/*/crash-reports/**"
    ];
    prepareCommands = [ "${lib.getExe pkgs.nixos-container} stop minecraft || true" ];
    cleanupCommands = [ "${lib.getExe pkgs.nixos-container} start minecraft || true" ];
  };
}
