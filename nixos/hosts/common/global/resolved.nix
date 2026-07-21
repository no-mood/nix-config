{
  config,
  lib,
  ...
}:
{
  # Systemd-resolved configuration with secure DNS settings
  # Provides DNS over TLS, DNSSEC validation, and reliable fallback DNS servers

  networking.nameservers = [
    "1.1.1.1" # Cloudflare primary
    "1.0.0.1" # Cloudflare secondary
  ];

  services.resolved = {
    enable = true;

    # Use this resolver for all domains (override any other DNS settings)
    # domains = [ "~." ];

    settings.Resolve = {
      # Enable DNSSEC validation for security
      DNSSEC = "true";

      # Fallback DNS servers when primary nameservers are unavailable
      FallbackDNS = [
        "1.1.1.1" # Cloudflare primary
        "1.0.0.1" # Cloudflare secondary
      ];

      # Enable DNS over TLS for encrypted DNS queries
      DNSOverTLS = "true";
    };
  };

}
