{
  pkgs,
  lib,
  ...
}:
{
  programs.gnupg = {
    agent = {
      enable = true;
      pinentryPackage = lib.mkDefault pkgs.pinentry-curses;
      enableSSHSupport = false;
    };
    dirmngr.enable = true;
  };
}
