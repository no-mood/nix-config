{ config, lib, ... }:
{
  options.networking.tailscaleAddress = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "The Tailscale address, derived from the hostname.";
  };

  config = {
    services.tailscale = {
      enable = true;
      port = 41641;
      openFirewall = true;
      useRoutingFeatures = "both";
      permitCertUid = lib.mkIf config.services.caddy.enable "caddy"; # Allow Caddy to manage Tailscale certificates
    };

    # Set the tailscale address when tailscale is enabled
    networking.tailscaleAddress = lib.mkIf config.services.tailscale.enable "${config.networking.hostName}.nyala-gacrux.ts.net";
  };

}
