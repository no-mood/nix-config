{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  programs.kitty = {
    enable = true;
    keybindings = {
      "ctrl+shift+t" = "new_tab_with_cwd"; # keybindings replaced with cwd
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+shift+n" = "new_os_window_with_cwd";
      "ctrl+shift+up" = "previous_window";
      "ctrl+shift+down" = "next_window";
    };
  };
}
