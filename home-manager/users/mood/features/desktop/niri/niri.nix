{
  config,
  lib,
  osConfig,
  ...
}:
let
  # niri fragments DMS writes at runtime under ~/.config/niri/dms/, derived from its
  # settings and editors (theme colors, displays, layout, cursor, ...). Optional so
  # the config also validates before DMS has written them.
  # binds.kdl comes last: it only holds keybinds changed from the DMS UI and
  # overrides ours until they are ported to ./binds.kdl.
  dmsFragments = [
    "colors"
    "input"
    "layout"
    "alttab"
    "outputs"
    "cursor"
    "windowrules"
    "wpblur"
    "binds"
  ];
  includeDms = name: ''include optional=true "${config.xdg.configHome}/niri/dms/${name}.kdl"'';
in
{
  wayland.windowManager.niri = {
    enable = true;
    package = osConfig.programs.niri.package;
    # The session and portals are set up by programs.niri on NixOS.
    systemd.enable = false;
    portalPackage = null;
    extraConfig = lib.concatLines (
      [
        (builtins.readFile ./config.kdl)
        (builtins.readFile ./binds.kdl)
      ]
      ++ map includeDms dmsFragments
    );
  };
}
