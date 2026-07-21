{
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    # https://github.com/NixOS/nixpkgs/tree/master/nixos/modules/installer/cd-dvd
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
  ];

  # Set system architecture
  nixpkgs.hostPlatform = "x86_64-linux";

  # Enable flakes and nix command
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Add useful tools to the installer
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    htop
    helix
    zellij
    yazi
    disko
    nixos-anywhere
    sops
    age
    ssh-to-age
    parted
    bcachefs-tools
  ];

  # Enable SSH for remote installation
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = false;
    };
  };

  # Enable Avahi for installer.local hostname resolution
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      domain = true;
    };
  };

  # Root password is handled by the installer module

  # Add SSH keys for remote access
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxbhFz7wWM0ohZry834Xk1VRRTw91h4dFW2kYALVWGG mood.dev"
  ];

  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxbhFz7wWM0ohZry834Xk1VRRTw91h4dFW2kYALVWGG mood.dev"
  ];

  # Enable bcachefs support, force disable ZFS (broken kernel module)
  boot.supportedFilesystems = {
    bcachefs = true;
    zfs = lib.mkForce false;
  };

  # System info
  system.stateVersion = "25.05";
}
