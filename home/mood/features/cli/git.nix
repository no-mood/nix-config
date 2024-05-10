{...}: {
  # TODO: use secrets, https://nixos.wiki/wiki/Git
  programs.git = {
    enable = true;
    userName = "mood";
    userEmail = "74420740+no-mood@users.noreply.github.com";
    lfs.enable = true;

    aliases = {
      ci = "commit";
      co = "checkout";
      s = "status";
    };
  };
}
