{
  pkgs,
  config,
  inputs,
  outputs,
  ...
}: let
  inherit (inputs.nix-colors.lib-contrib {inherit pkgs;}) gtkThemeFromScheme nixWallpaperFromScheme;
  colorScheme = config.colorScheme;
in {
  imports = [
    # ./pkg.nix
    inputs.nix-colors.homeManagerModule
  ];

  home.packages = with pkgs; [
    # pkg or unstable.pkg
  ];

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;

    theme =
      {
        dracula = {
          name = "Dracula";
          package = pkgs.dracula-theme;
        };
        catppuccin-latte = {
          name = "Catppuccin-Latte-Standard-Pink-Light";
          package = pkgs.catppuccin-gtk.override {
            accents = ["pink"];
            size = "standard";
            variant = "latte";
          };
        };
        catppuccin-frappe = {
          name = "Catppuccin-Frappe-Standard-Pink-Dark";
          package = pkgs.catppuccin-gtk.override {
            accents = ["pink"];
            size = "standard";
            variant = "frappe";
          };
        };
        catppuccin-macchiato = {
          name = "Catppuccin-Macchiato-Standard-Pink-Dark";
          package = pkgs.catppuccin-gtk.override {
            accents = ["pink"];
            size = "standard";
            tweaks = ["rimless" "black"];
            variant = "macchiato";
          };
        };
        catppuccin-mocha = {
          name = "Catppuccin-Mocha-Standard-Pink-Dark";
          package = pkgs.catppuccin-gtk.override {
            accents = ["pink"];
            size = "standard";
            tweaks = ["rimless" "black"];
            variant = "mocha";
          };
        };
      }
      .${config.colorScheme.slug}
      or {
        # Default case
        name = "${colorScheme.slug}";
        package = gtkThemeFromScheme {scheme = colorScheme;};
      };

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name =
        {
          dracula = "Papirus-Dark";
          catppuccin-latte = "Papirus-Light";
          catppuccin-frappe = "Papirus-Dark";
          catppuccin-macchiato = "Papirus-Dark";
          catppuccin-mocha = "Papirus-Dark";
        }
        .${config.colorScheme.slug}
        or "Papirus-Dark";
    };

    font = {
      name = "Sans";
      #size = 11;
    };
  };

  # gtk4 themes
  xdg.configFile = {
    "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
    "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
    "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
  };

  # Also sets org.freedesktop.appearance color-scheme
  dconf.settings."org/gnome/desktop/interface".color-scheme =
    if config.colorscheme.variant == "dark"
    then "prefer-dark"
    else if config.colorscheme.variant == "light"
    then "prefer-light"
    else "default";
}
