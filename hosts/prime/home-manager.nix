# Home-manager as a NixOS module
# https://github.com/Misterio77/nix-starter-configs#use-home-manager-as-a-nixos-module
{
  inputs,
  outputs,
  ...
}: {
  imports = [
    # Import home-manager's NixOS module
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users = {
      # Import your home-manager configuration
      mood = import ../../home/mood/prime.nix;
    };
  };
}
