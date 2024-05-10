{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # Import home-manager's NixOS module
    ../common/optional/home-manager.nix

    # Import home-manager's NixOS module
    ./services

    # Template-based. Add all users on this host
    ../common/global
    ../common/users/mood

    ../common/optional/systemd.nix
    ../common/optional/nvidia.nix

    #../common/optional/gnome.nix
    ../common/optional/gnome_specialisation.nix
    ../common/optional/hyprland.nix

    ../common/optional/virtualization.nix
    ../common/optional/wireless.nix
    #../common/optional/onedrive.nix
    ../common/optional/ratbagd.nix
    ../common/optional/gaming.nix
    ../common/optional/wireshark.nix
    ../common/optional/darkmode.nix
  ];

  home-manager.usernames = ["mood"];
  home-manager.hostname = "hpomen";
  #darkmode.username = "mood"; #TODO modularize this for all the users

  # TODO might change the kernel later
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.hostName = "hpomen"; # Define your hostname.
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
