{pkgs, ...}: {
  imports = [
    # ./pkg.nix
    ./firefox.nix
  ];

  home.packages = with pkgs; [
    # pkg or unstable.pkg

    google-chrome
    brave
  ];
}
