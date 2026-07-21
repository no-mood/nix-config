# Home-manager as a NixOS module
# https://github.com/Misterio77/nix-starter-configs#use-home-manager-as-a-nixos-module
{
  inputs,
  outputs,
  lib,
  config,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = lib.mkDefault true;
    useUserPackages = lib.mkDefault true;
    backupFileExtension = lib.mkDefault "hm-backup";
    extraSpecialArgs = { inherit inputs outputs; };
  };
}
