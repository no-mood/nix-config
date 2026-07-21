{
  # direnv automatically invokes nix develop. It works better with zsh
  programs = {
    direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };
  };
}
