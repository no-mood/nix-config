{ pkgs, ... }:
{
  home.packages = with pkgs; [
    proton-pass

    proton-vpn

    protonmail-bridge
    protonmail-bridge-gui
    protonmail-desktop
  ];
}
