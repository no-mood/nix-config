{ pkgs, ... }:
{
  imports = [
    # ./pkg.nix
  ];

  home.packages = with pkgs; [
    # pkg or unstable.pkg
    jetbrains.pycharm-professional

    # Clion
    (unstable.jetbrains.plugins.addPlugins unstable.jetbrains.clion [ "github-copilot" ])
  ];
}
