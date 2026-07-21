{
  config,
  lib,
  options,
  ...
}:
let
  # Common VM configuration to avoid duplication
  vmConfig = {
    security.sudo.wheelNeedsPassword = false;

    users.users.nixosvmtest.isSystemUser = true;
    users.users.nixosvmtest.initialPassword = "test";
    users.users.nixosvmtest.group = "nixosvmtest";
    users.groups.nixosvmtest = { };

    virtualisation = {
      memorySize = 4 * 1024; # KiB
      cores = 3;

      # Port forwarding for SSH access
      forwardPorts = [
        {
          from = "host";
          host.port = 2222;
          guest.port = 22;
        }
      ];
    };
  };
in
{
  config = {
    # The following configuration is added only when building VM with `build-vm`
    virtualisation.vmVariant = vmConfig;
    virtualisation.vmVariantWithBootloader = vmConfig;
  }
  // lib.optionalAttrs (options ? disko) {
    # Only set vmVariantWithDisko if disko options are available
    # Run with: nix run -L '.#nixosConfigurations.<hostname>.config.system.build.vmWithDisko'
    virtualisation.vmVariantWithDisko = vmConfig;
  };
}
