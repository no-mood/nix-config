{
  pkgs,
  ...
}:
{
  # Enable the GNOME Desktop Environment.
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # https://wiki.nixos.org/wiki/Remote_Desktop#XRDP
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session"; # gnome wayland session
  services.gnome.gnome-remote-desktop.enable = true; # needs gnome-remote-desktop backend to work!!
  services.displayManager.autoLogin.enable = false;
  services.getty.autologinUser = null;
  networking.firewall.allowedTCPPorts = [ 3389 ];

  # Gnome extensions
  services.gnome.gnome-browser-connector.enable = true;
  services.udev.packages = [ pkgs.gnome-settings-daemon ];

  programs.dconf.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;
}
