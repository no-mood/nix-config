{pkgs, ...}: let
  factorio = pkgs.unstable.factorio.override {
    username = "";
    token = "";
  };
in {
  imports = [
    # ./pkg.nix
  ];

  home.packages = with pkgs; [
    # pkg or unstable.pkg
    #sm64ex
    factorio #TODO use sops
  ];
}
