{pkgs, ...}: {
  home.packages = with pkgs; [
    # Gnome apps
    libadwaita
    gnome.adwaita-icon-theme
    gnome.nautilus # File Explorer
    gnome.cheese # Webcam
    gnome-text-editor # Text editor
    gnome.totem # video player
    loupe # Image viewer
    baobab # Disk Usage Analyzer
    evince # PDF Viewer

    gnome.gnome-screenshot
    gnome.gnome-calendar
    gnome.gnome-boxes
    gnome.gnome-system-monitor
    gnome.gnome-control-center
    gnome.gnome-weather
    gnome.gnome-calculator
    gnome.gnome-clocks
    gnome.gnome-software # for flatpak
    gnome.seahorse
    gcr_4
  ];
}
