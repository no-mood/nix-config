{ ... }:
{
  # Bootloader.
  boot.loader = {
    systemd-boot.enable = true;
    # Keep only the latest generations in the ESP (512M) so it cannot fill up.
    systemd-boot.configurationLimit = 5;
    efi.canTouchEfiVariables = true;
  };
}
