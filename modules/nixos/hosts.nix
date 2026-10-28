{ lib, options, ... }:
{
  options.myHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          builder = lib.mkOption {
            # Reuse the exact submodule used by nix.buildMachines, so definitions
            # are validated here without duplicating the option schema.
            type = options.nix.buildMachines.type.nestedTypes.elemType;
            description = "Build machine definition for this host.";
          };
          builderPublicKey = lib.mkOption {
            type = lib.types.str;
            description = "Public SSH key authorized for the nixremote build account.";
          };
        };
      }
    );
    default = { };
    description = "Per-host facts keyed by hostname.";
  };
}
