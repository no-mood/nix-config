{pkgs, ...}: {
  imports = [
    # ./pkg.nix
  ];

  programs.java.enable = true;
}
