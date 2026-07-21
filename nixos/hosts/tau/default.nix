{
  pkgs,
  ...
}:
{
  imports = [
    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # Import disko config
    ./disk-config.nix

    # Template-based. Add all users on this host
    ../common/global
    ../common/users/mood

    ../common/optional/systemd-boot.nix
    ./graphics.nix
    ../common/optional/drivers.nix
    #../common/optional/cuda.nix

    ../common/optional/gnome-DE.nix
    ../common/optional/niri.nix
    ../common/optional/printing.nix
    ../common/optional/kdeconnect.nix
    #../common/optional/cosmic-DE.nix

    ../common/optional/virtualisation.nix
    #../common/optional/wireless.nix
    ../common/optional/ratbagd.nix
    ../common/optional/gaming.nix
    ../common/optional/wireshark.nix
    ../common/optional/catppuccin.nix
    ../common/optional/bcc.nix
    ../common/optional/tailscale-client.nix
    ../common/optional/caddy.nix
    ../common/optional/restic-client.nix
    ../common/optional/sunshine-server.nix
  ];

  boot = {
    #kernelPackages = pkgs.linuxPackages;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.hostName = "tau"; # Define your hostname.

  environment.systemPackages = with pkgs; [
  ];

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11";
}
