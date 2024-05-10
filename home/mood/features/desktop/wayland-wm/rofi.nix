{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: {
  imports = [
    # ./pkg.nix
  ];

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = "solarized";
  };
}
