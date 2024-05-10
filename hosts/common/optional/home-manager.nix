# Home-manager as a NixOS module
# https://github.com/Misterio77/nix-starter-configs#use-home-manager-as-a-nixos-module
{
  inputs,
  outputs,
  lib,
  config,
  ...
}: let
  cfg = config.home-manager;
in {
  imports = [
    # Import home-manager's NixOS module
    inputs.home-manager.nixosModules.home-manager
  ];

  # Don't pass arguments, instead make an option. Source:
  # https://discourse.nixos.org/t/passing-parameters-into-import/34082/4
  options.home-manager = {
    hostname = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    usernames = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
    };
  };

  config = lib.mkIf ((cfg.hostname != null) && (cfg.usernames != null) && (lib.length cfg.usernames > 0)) {
    home-manager = {
      # useGlobalPkgs = lib.mkDefault true;

      # Enabling causes NixOS rebuilds to generate outputs in
      # /etc/profiles/per-user/$USER, which confuses PATH if running Home Manager
      # outside of NixOS generation. This is a workaround. In reality I'm likely
      # abusing Home Manager by using it both in- and out-side of nixos generations
      # on the same machine.
      # https://github.com/rummik/nixos-config/blob/f88adb6397cdbb775a1b699d866fcb43ef3611a6/profiles/core/common.nix#L14C2-L19C40

      # Trying it with true, and using nixos generations instead of HM
      useUserPackages = lib.mkDefault true;

      extraSpecialArgs = {inherit inputs outputs;};

      # Before moving the module to /hosts/common/optional
      # mood = import ../../home/mood/hpomen.nix;
      # ${username} = import ../../home/${username}/${cfg.hostname}.nix;

      users = builtins.listToAttrs (map (username: {
          name = username;
          value = import "${inputs.self}/home/${username}/${cfg.hostname}.nix";
        })
        cfg.usernames);
    };
  };
}
