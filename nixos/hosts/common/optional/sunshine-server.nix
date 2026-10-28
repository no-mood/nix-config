{
  config,
  lib,
  ...
}:
let
  webUIPort = 47990;
in
{
  services.sunshine = {
    enable = true;
    autoStart = false;
    capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
    openFirewall = true;
    # Permit the public Caddy reverse-proxy origin through Sunshine's CSRF check.
    settings.csrf_allowed_origins = lib.mkIf config.services.caddy.enable (
      "https://sunshine.${config.networking.hostName}.${config.sensitive.myDomain}"
    );
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
