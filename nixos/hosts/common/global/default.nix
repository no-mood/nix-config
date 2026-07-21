{
  config,
  pkgs,
  inputs,
  outputs,
  lib,
  ...
}:
{
  imports = [
    outputs.nixosModules.sensitive
    ./nix.nix
    ./nh.nix
    ./locale.nix
    ./resolved.nix
    ./ssh.nix
    ./gpg.nix
    ./pipewire.nix
    ./vm-test.nix
    ./fish.nix
    ./monitors.nix
    ./sops.nix
    ./home-manager.nix
    ./nixpkgs.nix
    ./documentation.nix
    ./fonts.nix
    ./avahi.nix
    ./sudo-rs.nix
  ]
  ++ lib.optional (builtins.pathExists ./sensitive.nix) ./sensitive.nix;

  system.stateVersion = lib.mkDefault "26.05";
}
