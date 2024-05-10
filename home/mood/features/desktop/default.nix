{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    # ./pkg.nix
    ./wayland-wm
    ./gtk.nix
    ./gnome.nix
    ./theme.nix
    #./catppuccin.nix
  ];

  home.packages = with pkgs; [
    # pkg or unstable.pkg
  ];
}
