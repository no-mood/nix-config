{
  inputs,
  outputs,
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (inputs.nix-colors) colorSchemes;
  inherit (inputs.nix-colors.lib-contrib {inherit pkgs;}) nixWallpaperFromScheme;
in {
  imports = [
    inputs.nix-colors.homeManagerModules.default
    outputs.homeManagerModules.rice
  ];

  # To import all the modules from the outputs, use:
  #++ (builtins.attrValues outputs.homeManagerModules); # Importing a custom hm-module set in outputs

  # Theme set in this file instead of home/$user/$host.nix
  # Taken from
  # https://github.com/tinted-theming/schemes/tree/spec-0.11/base16

  #
  # catppuccin-latte
  # catppuccin-frappe
  # catppuccin-macchiato
  # catppuccin-mocha
  # tokyo-night-dark
  # tokyo-night-storm
  # tokyo-night-moon
  # tokyo-night-light
  #

  rice = {
    enable = true;
    colormode = lib.mkDefault "light";
    lightTheme = "catppuccin-latte";
    darkTheme = "catppuccin-macchiato";
  };

  rice.wallpaper = nixWallpaperFromScheme {
    scheme = config.colorScheme;
    width = 2560;
    height = 1440;
    logoScale = 8;
    #logoColor1 = config.colorScheme.palette.base03;
    #logoColor2 = config.colorScheme.palette.base04;
  };

  # TODO fix this, go back to light mode
  home.packages = let
    toggle-theme = pkgs.writeShellScriptBin "toggle-theme" ''
      # Get the current color scheme variant
      current_mode=${lib.escapeShellArg config.rice.colormode}

      if [[ "$current_mode" = "dark" ]]; then
        echo "Dark mode is currently active."
        echo "Switching to light mode."
        sudo /run/current-system/bin/switch-to-configuration switch
      else
        echo "Light mode is currently active."
        echo "Switching to dark mode."
        sudo /run/current-system/specialisation/darkmode/bin/switch-to-configuration switch
      fi
    '';
  in [toggle-theme];
}
