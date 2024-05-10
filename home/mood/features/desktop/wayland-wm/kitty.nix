{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: {
  imports = [
    # ./pkg.nix
  ];
  home.packages = with pkgs; [
  ];

  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    theme =
      {
        catppuccin-latte = "Catppuccin-Frappe";
        catppuccin-frappe = "Catppuccin-Frappe";
        catppuccin-macchiato = "Catppuccin-Macchiato";
        catppuccin-mocha = "Catppuccin-Mocha";

        tokyo-night-dark = "Tokyo Night";
        tokyo-night-storm = "Tokyo Night Storm";
        tokyo-night-moon = "Tokyo Night Moon";
        tokyo-night-light = "Tokyo Night Day";
      }
      .${config.colorScheme.slug}
      or "Default";
    keybindings = {
      "ctrl+shift+t" = "new_tab_with_cwd"; # keybindings replaced with cwd
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+shift+n" = "new_os_window_with_cwd";
      "ctrl+shift+up" = "previous_window";
      "ctrl+shift+down" = "next_window";
    };
  };
}
