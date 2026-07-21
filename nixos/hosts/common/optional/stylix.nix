{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  environment.systemPackages =
    let
      toggle-theme = pkgs.writeShellScriptBin "toggle-theme" ''
        # Get the current color scheme polarity
        polarity=${lib.escapeShellArg config.stylix.polarity}

        if [[ "$polarity" = "dark" ]]; then
          echo "Dark mode is currently active."
          echo "Switching to light mode."
          sudo nixos-rebuild test
        else
          echo "Light mode is currently active."
          echo "Switching to dark mode."
          sudo nixos-rebuild test --specialisation toggle_theme
        fi
      '';
    in
    [ toggle-theme ];

  stylix = {
    enable = true;
    # https://github.com/nix-community/stylix/issues/929

    homeManagerIntegration.autoImport = true; # Default is true
    homeManagerIntegration.followSystem = true; # Default is true

    base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    polarity = lib.mkDefault "dark";

    # TODO switch to a more dynamic way, just like misterio77/nix-colors
    image = lib.mkDefault "${pkgs.nixos-artwork.wallpapers.simple-dark-gray}/share/backgrounds/nixos/nix-wallpaper-simple-dark-gray.png";
    # image = lib.mkDefault config.lib.stylix.pixel "base0A";

    opacity = {
      applications = 1.0;
      terminal = 1.0;
      desktop = 1.0;
      popups = 1.0;
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 14;
    };

    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        applications = 12; # 12
        terminal = 12; # 15
        desktop = 12; # 10
        popups = 12; # 10
      };
    };

    targets = {
      gtksourceview.enable = false;
    };

  };

  specialisation.toggle_theme.configuration = {
    environment.etc."specialisation".text = "toggle_theme";
    # sudo nixos-rebuild test --specialisation toggle_theme
    stylix = {
      image = lib.mkForce "${pkgs.nixos-artwork.wallpapers.simple-blue}/share/backgrounds/nixos/nix-wallpaper-simple-blue.png";
      polarity = lib.mkForce "light";
      base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";
    };
  };
}
