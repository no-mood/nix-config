{
  pkgs,
  lib,
  osConfig,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      # Not included in the gnome NixOS module, usually Gnome Circle Apps
      newsflash # RSS reader (gnome-circle)
      gnome-boxes # VM manager
    ]
    ++ lib.optionals (!(osConfig.services.desktopManager.gnome.enable or false)) [
      # Included by the gnome NixOS module when enabled; add here otherwise
      # Add here when needed
    ];
}
