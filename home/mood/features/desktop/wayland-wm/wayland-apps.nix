{pkgs, ...}: {
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  home.packages = with pkgs; [
    # pkg or unstable.pkg
    xorg.xeyes # If eyes move, the app is using xwayland
    wl-clipboard
    unstable.hyprshot

    pavucontrol # audio control
    playerctl # controlling media player

    # mako # Notification daemon, using ags
    kitty #terminal emulator

    swww # Wallpaper
    waypaper # GUI for swww or swaybg

    grim # TMP for screenshots
    slurp
  ];
}
