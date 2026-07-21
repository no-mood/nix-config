{
  pkgs,
  ...
}:
{
  home.packages = with pkgs.gnomeExtensions; [
    pkgs.gnome-browser-connector
    pkgs.gnome-tweaks
    user-themes
    appindicator
    paperwm
    freon
    night-theme-switcher
  ];

  dconf = {
    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false; # enables user extensions
        enabled-extensions = with pkgs.gnomeExtensions; [
          # Put UUIDs of extensions that you want to enable here.
          # If the extension you want to enable is packaged in nixpkgs,
          # you can easily get its UUID by accessing its extensionUuid
          # field (look at the following example).
          gsconnect.extensionUuid
          user-themes.extensionUuid
          appindicator.extensionUuid
          paperwm.extensionUuid
          freon.extensionUuid
          night-theme-switcher.extensionUuid

          # Alternatively, you can manually pass UUID as a string.
          #"blur-my-shell@aunetx"
          # ...
        ];
      };
      "org/gnome/mutter" = {
        experimental-features = [
          "scale-monitor-framebuffer"
          "variable-refresh-rate"
        ];
      };
    };
  };
}
