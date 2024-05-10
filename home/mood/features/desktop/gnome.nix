{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    # pkg or unstable.pkg
    #papirus-icon-theme
    gnome-browser-connector
    gnome.gnome-tweaks
  ];

  #config.firefox.enableGnomeExtensions = true;
}
