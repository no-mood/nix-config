{ pkgs, ... }:
{
  programs.fastfetch = {
    enable = true;
    package = pkgs.fastfetch;
    settings = {
      logo = {
        source = "NixOS_small";
        padding = {
          top = 0;
          right = 2;
          bottom = 0;
          left = 0;
        };
      };
      display = {
        separator = "  ";
      };
      modules = [
        {
          type = "title";
          keyWidth = 0;
          format = "{user-name}@{host-name}";
        }
        "separator"
        "os"
        "kernel"
        "uptime"
        "shell"
        "terminal"
        "wm"
      ];
    };
  };
}
