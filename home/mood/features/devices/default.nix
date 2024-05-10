{pkgs, ...}: {
  imports = [
    # ./pkg.nix
  ];

  home.packages = with pkgs; [
    # pkg or unstable.pkg

    # For logitech mice, services enabled in services
    piper
  ];
}
