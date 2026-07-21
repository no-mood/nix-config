{ config, ... }:
let
  webUIPort = 47990;
in
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
    openFirewall = true;
  };

  services.caddy.virtualHosts."sunshine.${config.networking.hostName}.${config.sensitive.myDomain}".extraConfig =
    ''
      reverse_proxy https://127.0.0.1:${toString webUIPort} {
        transport http {
          tls_insecure_skip_verify
        }
      }
    '';
}
