{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
    keymap = {
      mgr = {
        prepend_keymap = [
          {
            on = [
              "g"
              "i"
            ];
            run = "plugin lazygit";
            desc = "run lazygit";
          }
          {
            on = [
              "g"
              "c"
            ];
            run = "plugin vcs-files";
            desc = "show git changes";
          }
        ];
      };
    };
    initLua = ''
      require("git"):setup()
    '';
    settings = {
      plugin.prepend_fetchers = [
        {
          id = "git";
          url = "*";
          run = "git";
        }
        {
          id = "git";
          url = "*/";
          run = "git";
        }
      ];
    };
    theme = { };

    plugins = {
      inherit (pkgs.yaziPlugins)
        git # https://github.com/yazi-rs/plugins/tree/main/git.yazi
        lazygit # https://github.com/Lil-Dank/lazygit.yazi
        vcs-files # https://github.com/yazi-rs/plugins/tree/main/vcs-files.yazi
        ;
    };
  };

  home.packages = with pkgs; [
    lazygit
  ];
}
