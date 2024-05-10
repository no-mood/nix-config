{
  lib,
  config,
  inputs,
  ...
}: let
  inherit (inputs.nix-colors) colorSchemes;
  cfg = config.rice;
in {
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];

  options.rice = {
    enable = lib.mkEnableOption ''
      Rice customization with this module.
    '';

    colormode = lib.mkOption {
      type = lib.types.enum ["dark" "light"];
      default = "light";
      description = "Theme mode. Can be 'light' or 'dark'.";
    };

    theme = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      readOnly = true; # Theme is set in the module
      description = "Theme name";
    };

    lightTheme = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Theme name";
    };

    darkTheme = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Theme name";
    };

    wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Wallpaper path
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    rice.theme =
      if (cfg.colormode == "light")
      then cfg.lightTheme
      else if (cfg.colormode == "dark")
      then cfg.darkTheme
      else null;

    colorScheme = colorSchemes.${cfg.theme};
  };
}
