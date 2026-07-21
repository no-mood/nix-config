{ pkgs, ... }:
{
  imports = [
    ./kitty.nix
    ./foot.nix
    ./wayland-apps.nix
  ];

  home.packages = with pkgs; [
    # pkg or unstable.pkg
  ];
}
