{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
{
  programs.foot = {
    enable = true;

    # https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
    settings = {
      main = {
        "dpi-aware" = lib.mkDefault "yes";
      };
      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}
