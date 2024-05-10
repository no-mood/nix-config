{
  config,
  pkgs,
  ...
}: {
  # Enable zsh
  programs.zsh = {
    enable = true; # installed system-wide, has to be enabled here to be managed by home-manager. Check config/hosts/common/global/zsh.nix
    defaultKeymap = "vicmd";
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
    };

    oh-my-zsh = {
      enable = true;
      plugins = ["git" "sudo"];
      theme = "minimal";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
