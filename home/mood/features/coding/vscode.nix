# https://nixos.wiki/wiki/Visual_Studio_Code
{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
      #dracula-theme.theme-dracula
      #vscodevim.vim
      #yzhang.markdown-all-in-one
    ];
  };
}
