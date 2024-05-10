{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./nix.nix
    ./locale.nix
    ./openssh.nix
    ./pipewire.nix
    ./vm.nix
    ./zsh.nix
    ./gparted.nix
  ];

  # Allow unfree packages
  nixpkgs = {
    config.allowUnfree = true;
  };

  boot.supportedFilesystems = ["ntfs"];

  programs.dconf.enable = true;
  programs.kdeconnect.enable = true;
}
