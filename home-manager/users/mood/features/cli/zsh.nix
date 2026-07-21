{ osConfig, ... }:
{
  programs.zsh = {
    enable = osConfig.programs.zsh.enable; # must be enabled system-wide
    defaultKeymap = "viins";
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
      ];
      theme = "minimal";
    };
  };
}
