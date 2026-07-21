{
  pkgs,
  config,
  inputs,
  lib,
  options,
  osConfig,
  ...
}:
{
  imports = [
    # ./noctalia-shell.nix
    ./dank-material-shell.nix
  ];

  # Additional packages for niri
  home.packages = with pkgs; [
    xwayland-satellite
    brightnessctl
    playerctl
  ];
}
