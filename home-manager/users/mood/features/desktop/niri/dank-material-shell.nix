{
  lib,
  inputs,
  osConfig,
  ...
}:
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
  ];

  programs.dank-material-shell = {
    enable = true;
    settings = import ./dms-settings.nix;
    # Start only in niri sessions, not in every graphical session (e.g. GNOME).
    systemd.enable = true;
    systemd.target = lib.mkIf osConfig.programs.niri.enable "niri.service";
  };
}
