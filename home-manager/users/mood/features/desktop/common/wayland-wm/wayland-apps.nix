{ pkgs, ... }:
{
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  home.packages = with pkgs; [
    xeyes # If eyes move, the app is using xwayland
    wl-clipboard
    hyprshot

    pavucontrol # audio control
    playerctl # controlling media player

    grim # For screenshots
    slurp

    waypipe # For remote wayland applications
  ];
}
