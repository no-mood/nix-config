{...}: {
  services.blueman.enable = true;

  services.iperf3 = {
    enable = true;
    openFirewall = true;
  };
}
