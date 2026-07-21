{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
  ];

  home-manager.sharedModules = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };

}
