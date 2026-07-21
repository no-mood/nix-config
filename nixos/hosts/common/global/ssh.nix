{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  hosts = lib.attrNames outputs.nixosConfigurations;
in
{
  # Thanks @misterio77 for the idea

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    # Forbid root login through SSH.
    settings.PermitRootLogin = "no";

    # Use keys only. Remove if you want to SSH using password (not recommended)
    settings.PasswordAuthentication = false;

    # NixOS can automatically generate SSH host keys
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        bits = 4096;
        path = "/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
    ];
  };

  # Passwordless sudo when SSH'ing with keys with agent forwarding (-A)
  security.pam.sshAgentAuth = {
    enable = true;
    authorizedKeysFiles = [ "/etc/ssh/authorized_keys.d/%u" ];
  };

  programs.ssh = {
    # Each host's public key
    knownHosts = lib.genAttrs hosts (
      hostname:
      let
        path = ../../${hostname}/ssh_host_ed25519_key.pub;
      in
      lib.mkIf (builtins.pathExists path) {
        # Only set this if the file exists
        publicKeyFile = path;
        extraHostNames =
          # Alias for localhost if it's the same host
          lib.optional (hostname == config.networking.hostName) "localhost";
      }
    );
  };
}
