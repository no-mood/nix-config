{
  config,
  lib,
  ...
}:
let
  hostDomain = "${config.networking.hostName}.${config.sensitive.myDomain}";
in
{
  sops.secrets.cloudflare-ddns-token = {
    key = "cloudflare/tls_token";
  };

  sops.templates."cloudflare-ddns.env" = {
    content = ''
      CLOUDFLARE_API_TOKEN=${config.sops.placeholder.cloudflare-ddns-token}
    '';
    restartUnits = [ "cloudflare-ddns.service" ];
  };

  services.cloudflare-ddns = {
    enable = true;
    credentialsFile = config.sops.templates."cloudflare-ddns.env".path;
    domains = [
      hostDomain
      "*.${hostDomain}"
    ];
    provider = {
      ipv4 = "local.iface:tailscale0";
      ipv6 = "local.iface:tailscale0";
    };
    proxied = "false";
    recordComment = "Managed by NixOS on ${config.networking.hostName}";
  };

  systemd.services.cloudflare-ddns = {
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
    # The local.iface providers inspect interface addresses through netlink.
    serviceConfig.RestrictAddressFamilies = lib.mkAfter [ "AF_NETLINK" ];
  };
}
