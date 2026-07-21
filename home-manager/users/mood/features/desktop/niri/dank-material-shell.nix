{
  config,
  lib,
  inputs,
  osConfig,
  ...
}:

let
  niriDir = "${osConfig.programs.nh.flake}/home-manager/users/mood/features/desktop/niri";
in
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
  ];

  programs.dank-material-shell = {
    enable = true;
  };

  # Niri configuration - symlink to flake in system, not nix store
  # Wait for the niri module: https://github.com/nix-community/home-manager/pull/8700

  xdg.configFile = {
    "niri/config.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/config.kdl";
    "niri/dms/alttab.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/alttab.kdl";
    "niri/dms/binds.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/binds.kdl";
    "niri/dms/colors.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/colors.kdl";
    "niri/dms/cursor.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/cursor.kdl";
    "niri/dms/layout.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/layout.kdl";
    "niri/dms/outputs.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/outputs.kdl";
    "niri/dms/windowrules.kdl".source =
      config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/windowrules.kdl";
    "niri/dms/wpblur.kdl".source = config.lib.file.mkOutOfStoreSymlink "${niriDir}/dms/wpblur.kdl";
  };
}
