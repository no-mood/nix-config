# https://home-manager-options.extranix.com/?query=vscode&release=master
{
  pkgs,
  ...
}:
{
  programs.vscode = with pkgs; {
    enable = true;
    package = vscode;

    # `mutableExtensionsDir` defaults to:
    # (removeAttrs config.programs.vscode.profiles [ "default" ]) == { }
    # Which means that if we only have the default profile, it will set to true;
    # However we still want it false, so we set it to false explicitly.
    mutableExtensionsDir = true;

    profiles.default = {
      extensions =
        with vscode-extensions;
        [
          #dracula-theme.theme-dracula
          #vscodevim.vim
          #yzhang.markdown-all-in-one
          mkhl.direnv
          jnoortheen.nix-ide
          james-yu.latex-workshop
          github.copilot
          github.copilot-chat
          ms-pyright.pyright
          ms-vscode.cpptools
          ms-azuretools.vscode-docker
          mechatroner.rainbow-csv
          ms-toolsai.jupyter
          eamodio.gitlens
          scala-lang.scala
        ]
        ++ vscode-utils.extensionsFromVscodeMarketplace [
          # {
          #   name = "vscode-helix-emulation";
          #   publisher = "jasew";
          #   version = "0.6.3";
          #   hash = "sha256-iHPAFzo1sJI+TMk0pzkuOPw2pTo7g44cZd1EWIifHyM=";
          # }
        ];
      userSettings = {
        "editor.wordWrap" = "on";

        # Theming
        "workbench.iconTheme" = lib.mkDefault "material-icon-theme";
        "window.titleBarStyle" = "custom";
        #"window.zoomLevel" = 0.5;

        # Javascript
        "[javascript]" = {
          "editor.formatOnSave" = true;
          "editor.defaultFormatter" = "vscode.typescript-language-features";
        };
        "[javascriptreact]" = {
          "editor.defaultFormatter" = "vscode.typescript-language-features";

          "editor.formatOnSave" = true;
        };
        "[cpp]" = {
          "editor.defaultFormatter" = "ms-vscode.cpptools";
        };
        # Latex
        "latex-workshop.formatting.latex" = "latexindent";

        # Copilot
        "github.copilot.enable" = {
          "markdown" = true;
        };
      };
    };
  };
}
