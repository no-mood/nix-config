{
  config,
  pkgs,
  ...
}: {
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "mood";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Gnome extensions
  services.gnome.gnome-browser-connector.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable xserver
  services.xserver.enable = true;

  # Configure keymap in xserver
  services.xserver = {
    layout = "it";
    xkbVariant = "us";
  };
}
