{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  imports = [
    # ./pkg.nix
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  catppuccin.flavour = "mocha";

  wayland.windowManager.hyprland.catppuccin.enable = true;

  home.packages = with pkgs; [
    # pkg or unstable.pkg
  ];
}
