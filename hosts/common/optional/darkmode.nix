{
  lib,
  config,
  ...
}: let
  cfg = config.darkmode;
in {
  options.darkmode = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "mood";
    };
  };

  config = {
    specialisation = {
      darkmode = {
        inheritParentConfig = true;
        configuration = {
          system.nixos.tags = ["darkmode"];
          home-manager.users.${cfg.username}.rice.colormode = "dark"; # TODO modularize this and move this elsewhere
        };
      };
    };
  };
}
