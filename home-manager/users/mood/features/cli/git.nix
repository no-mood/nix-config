{ pkgs, osConfig, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.git.override { withLibsecret = true; };
    lfs.enable = true;
    signing.format = "ssh";

    settings = {
      user = {
        name = "mood";
        email = osConfig.sensitive.devEmail;
      };

      alias = {
        ci = "commit";
        co = "checkout";
        s = "status";
      };

      credential.helper = "libsecret";
      color.ui = true;
      push.autoSetupRemote = true;
      http.postBuffer = 524288000; # https://stackoverflow.com/questions/6842687/the-remote-end-hung-up-unexpectedly-while-git-cloning
    };
  };
}
