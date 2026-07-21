{ pkgs, ... }:
{
  boot.kernelModules = [ "i2c-dev" ];
  environment.systemPackages = [
    pkgs.ddcutil
  ];

  users.groups.i2c = { };
}
