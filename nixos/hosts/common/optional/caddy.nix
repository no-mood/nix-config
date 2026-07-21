{
  pkgs,
  config,
  lib,
  ...
}:

{
  config = {
    services.caddy = {
      # Enable Caddy
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/cloudflare@v0.2.4" # https://github.com/caddy-dns/cloudflare/tags
        ];
        hash = "sha256-hEHgAG0F0ozHRAPuxEqLyTATBrE+pajeXDiSNwniorg=";
      };
      environmentFile = config.sops.templates.caddy.path;
      globalConfig = ''
        acme_dns cloudflare {env.CF_API_TOKEN}
        ${lib.optionalString (
          (config.services.resolved.settings.Resolve.DNSSEC or "false") == "true"
          || (config.services.resolved.settings.Resolve.DNSOverTLS or "false") == "true"
        ) "tls_resolvers 1.1.1.1 1.0.0.1"}
      '';
    };

    sops.secrets.cf-api-token = {
      key = "cloudflare/tls_token"; # https://www.youtube.com/watch?v=zCyx4vmp4k0
      owner = config.services.caddy.user;
      restartUnits = [ "caddy.service" ];
    };

    sops.templates.caddy = {
      content = "CF_API_TOKEN=${config.sops.placeholder.cf-api-token}";
      owner = config.services.caddy.user;
    };

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    # Allow unprivileged processes (e.g., devenv's Caddy) to bind to ports >=80.
    # This lowers the privileged port floor globally; use only on trusted hosts.
    boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

    # Each config is in its separate module
  };
}
