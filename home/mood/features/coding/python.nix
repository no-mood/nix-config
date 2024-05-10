{pkgs, ...}: {
  imports = [
    # ./pkg.nix
  ];

  #let
  #my-python-packages = ps: with ps; [
  #  pandas
  #  requests
  #  # other python packages
  #];
  #in

  home.packages = with pkgs; [
    # pkg or unstable.pkg
    # python3
  ];
}
