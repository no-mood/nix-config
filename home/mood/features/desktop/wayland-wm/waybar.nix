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

  programs.waybar = {
    enable = true;
    settings = {
    };
  };
}
