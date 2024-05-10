{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    # ./pkg.nix
    ./gnome-apps.nix
    ./wayland-apps.nix

    ./hyprland
    ./rofi.nix
    ./ags.nix
    #./waybar.nix

    ./kitty.nix # TODO move this elsewhere
  ];

  home.packages = with pkgs; [
    # pkg or unstable.pkg
  ];
}
