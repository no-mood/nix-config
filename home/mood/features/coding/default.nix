{pkgs, ...}: {
  imports = [
    # ./pkg.nix
    ./vscode.nix
    ./jetbrains.nix
    ./texlive.nix
    #./java.nix
    #./python.nix
  ];

  home.packages = with pkgs; [
    # pkg or unstable.pkg
    eclipses.eclipse-cpp
  ];
}
