{
  lib,
  config,
  pkgs,
  ...
}: {
  specialisation = {
    gnome = {
      inheritParentConfig = true;
      configuration = {
        system.nixos.tags = ["GNOME"];
        imports = [./gnome.nix];
        services.xserver.enable = true;
        services.xserver.displayManager.gdm.enable = true;
        services.xserver.desktopManager.gnome.enable = true;
        # programs.hyprland.enable = lib.mkForce false;
      };
    };
  };
}
