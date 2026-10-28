{
  config,
  inputs,
  pkgs,
  ...
}:
let
  cacheName = "mesh";
  cacheEndpoint = "https://cache.${config.sensitive.myDomain}";
  cachePublicKey = "mesh:Eayigxd+Wvm3/pJOgtqWIcQPWN+8Qa7hUSpLwKbWo9g=";
  attic = inputs.attic.packages.${pkgs.stdenv.hostPlatform.system}.attic-client;
  clientConfig = pkgs.formats.toml { };
  configFile = clientConfig.generate "attic-client.toml" {
    default-server = "lyr";
    servers.lyr = {
      endpoint = cacheEndpoint;
      token-file = config.sops.secrets."attic/push-token".path;
    };
  };
  configHome = pkgs.runCommand "attic-client-config" { } ''
    mkdir -p "$out/attic"
    ln -s ${configFile} "$out/attic/config.toml"
  '';
in
{
  # Attic signs cache paths on the server. No upload credentials go into the Nix store.
  nix.settings = {
    extra-substituters = [ "${cacheEndpoint}/${cacheName}" ];
    extra-trusted-public-keys = [ cachePublicKey ];
    # Build locally when the central cache is temporarily unavailable.
    fallback = true;
  };

  sops.secrets."attic/push-token" = {
    sopsFile = inputs.self.outPath + "/nixos/hosts/common/secrets.yaml";
    owner = "root";
    group = "root";
    mode = "0400";
    restartUnits = [ "attic-watch-store.service" ];
  };

  environment.systemPackages = [ attic ];

  systemd.services.attic-watch-store = {
    description = "Push new Nix store paths to the Attic cache on lyr";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${attic}/bin/attic watch-store lyr:${cacheName}";
      Environment = "XDG_CONFIG_HOME=${configHome}";
      Restart = "always";
      RestartSec = 60;
    };
  };

  # watch-store only observes new paths; retry the current system closure after downtime.
  systemd.services.attic-push-system = {
    description = "Retry uploading the current NixOS system to Attic";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      Environment = "XDG_CONFIG_HOME=${configHome}";
      ExecStart = "${attic}/bin/attic push lyr:${cacheName} /run/current-system";
    };
  };
  systemd.timers.attic-push-system = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10min";
      OnCalendar = "hourly";
      Persistent = true;
    };
  };
}
