{
  # Avahi daemon for mDNS/DNS-SD service discovery
  # Enables hostname.local resolution across the network
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Resolve .local hostnames (IPv4)
    nssmdns6 = true; # Resolve .local hostnames (IPv6)
    openFirewall = true; # Open mDNS port (5353/udp)
    publish = {
      enable = true;
      addresses = true; # Publish this machine's IP addresses
      workstation = true; # Announce as workstation type
      userServices = true; # Allow users to publish services
      domain = true; # Publish local domain info
    };
  };
}
