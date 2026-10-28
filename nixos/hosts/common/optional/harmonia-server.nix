{ config, ... }:
let
  port = 5000;
in
{
  sops.secrets."harmonia/signing-key" = {
    restartUnits = [ "harmonia.service" ];
  };

  # Serve the local store; client cache settings live in harmonia-client.nix.
  services.harmonia.cache = {
    enable = true;
    signKeyPaths = [ config.sops.secrets."harmonia/signing-key".path ];
    settings = {
      bind = "127.0.0.1:${toString port}";
      priority = 40;
      workers = 4;
    };
  };

  services.caddy.virtualHosts."harmonia.${config.sensitive.myDomain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString port}
  '';
}
