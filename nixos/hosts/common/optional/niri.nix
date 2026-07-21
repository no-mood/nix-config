{ lib, ... }:
{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  programs.niri.enable = true;

  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
}
