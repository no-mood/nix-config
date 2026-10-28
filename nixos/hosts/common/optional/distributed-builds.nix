{
  config,
  pkgs,
  lib,
  ...
}:
let
  nixDaemon = "${config.nix.package}/bin/nix-daemon";
  builderKeys = lib.mapAttrsToList (
    _: hostCfg: ''restrict,command="${nixDaemon} --stdio" ${hostCfg.builderPublicKey}''
  ) config.myHosts;
  hostName = config.networking.hostName;
  self = config.myHosts.${hostName} or null;
  # Offload only to peers faster than this host; a host not listed in myHosts uses every peer.
  # The local builder is never listed: Nix has no speedFactor for it and a self-remote
  # builder deadlocks.
  # https://github.com/NixOS/nix/issues/2457
  # https://github.com/NixOS/nix/issues/2029
  fasterPeers = lib.filter (
    b: b.hostName != hostName && (self == null || b.speedFactor > self.builder.speedFactor)
  ) (lib.mapAttrsToList (_: hostCfg: hostCfg.builder) config.myHosts);
in
{
  users.groups.nixremote = { };

  users.users.nixremote = {
    isSystemUser = true;
    group = "nixremote";
    description = "Nix remote build service account";
    home = "/var/empty";
    createHome = false;
    shell = pkgs.bash;
    hashedPassword = "!";
    openssh.authorizedKeys.keys = builderKeys;
  };

  nix = {
    distributedBuilds = true;
    buildMachines = fasterPeers;
    settings = {
      builders-use-substitutes = true;
      trusted-users = [ "nixremote" ];
    };
  };
}
