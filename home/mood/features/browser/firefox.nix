{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # ./pkg.nix
  ];

  home.packages = with pkgs; [
    # pkg or unstable.pkg
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox (pkgs.firefox-unwrapped.override {pipewireSupport = true;}) {};
  };
}
