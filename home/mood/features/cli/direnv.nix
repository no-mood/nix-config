{
  # direnv automatically invokes nix develop. It works better with zsh
  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # bash.enable = true;
  };
}
