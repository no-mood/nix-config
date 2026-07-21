{
  config,
  lib,
  pkgs,
  ...
}:
let
  port = 8000;
in
{
  # Enable restic REST server
  services.restic.server = {
    enable = true;

    # Listen on localhost only (behind reverse proxy)
    listenAddress = "127.0.0.1:${toString port}";

    # Data directory for repositories
    dataDir = "/var/lib/restic";

    privateRepos = false;
    htpasswd-file = config.sops.secrets."restic/local/htpasswd".path;
  };

  sops.secrets."restic/local/htpasswd" = {
    owner = "restic";
    restartUnits = [ "restic-rest-server.service" ];
  };

  # Caddy reverse proxy configuration
  services.caddy = {
    virtualHosts."restic.${config.sensitive.myDomain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString port}
    '';
  };

  # Optional: Prometheus monitoring endpoint
  # Uncomment if you want metrics
  # services.restic.server.prometheus = true;
}
