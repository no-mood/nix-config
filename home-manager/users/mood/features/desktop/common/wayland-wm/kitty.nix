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

    settings = {
      enable_audio_bell = false;
      scrollback_lines = 10000;
    };

    keybindings = {
      "ctrl+shift+t" = "new_tab_with_cwd"; # keybindings replaced with cwd
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+shift+n" = "new_os_window_with_cwd";
      "ctrl+shift+left" = "neighboring_window left";
      "ctrl+shift+down" = "neighboring_window down";
      "ctrl+shift+up" = "neighboring_window up";
      "ctrl+shift+right" = "neighboring_window right";
      "ctrl+shift+h" = "neighboring_window left";
      "ctrl+shift+j" = "neighboring_window down";
      "ctrl+shift+k" = "neighboring_window up";
      "ctrl+shift+l" = "neighboring_window right";
    };
  };
}
