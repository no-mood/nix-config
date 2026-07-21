{ pkgs, ... }:
{
  # Common drivers, all in this file

  # Pantum printer driver
  services.printing.drivers = with pkgs; [ pantum-driver ];

  # NTFS driver
  boot.supportedFilesystems = [ "ntfs" ];

}
