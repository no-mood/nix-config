{
  # Avahi daemon for mDNS/DNS-SD service discovery
  # Enables hostname.local resolution across the network
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Resolve .local hostnames (IPv4)
    nssmdns6 = true; # Resolve .local hostnames (IPv6)
    openFirewall = true; # Open mDNS port (5353/udp)
    settings.publish = {
      disable-publishing = false;
      publish-addresses = true; # Publish this machine's IP addresses
      publish-workstation = true; # Announce as workstation type
      disable-user-service-publishing = false; # Allow users to publish services
      publish-domain = true; # Publish local domain info
    };
  };
}
