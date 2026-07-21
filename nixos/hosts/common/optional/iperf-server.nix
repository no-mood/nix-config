{ config, pkgs, ... }:
{
  services.iperf3 = {
    enable = true;
    port = 5201;
    openFirewall = true;
  };

  services.caddy = {
    virtualHosts."iperf.${config.sensitive.myDomain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString config.services.iperf3.port}
    '';
  };
}
