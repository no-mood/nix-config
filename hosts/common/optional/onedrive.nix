{pkgs, ...}: {
  # Onedrive
  services.onedrive.enable = true;

  # Onedrive GUI
  environment.systemPackages = [
    pkgs.onedrivegui
  ];
}
