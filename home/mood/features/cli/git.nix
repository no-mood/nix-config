{ ... }: {

# TODO: use secrets, https://nixos.wiki/wiki/Git
programs.git = {
    enable = true;
    userName  = "mood";
    userEmail = "g.nicosia00@gmail.com";
  };

}
