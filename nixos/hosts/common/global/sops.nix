{
  inputs,
  config,
  pkgs,
  ...
}:
let
  isEd25519 = k: k.type == "ed25519";
  getKeyPath = k: k.path;
  keys = builtins.filter isEd25519 config.services.openssh.hostKeys;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = with pkgs; [
    sops
    ssh-to-age
    ssh-to-pgp
  ];

  # This will add secrets.yml to the nix store
  # You can avoid this by adding a string to the full path instead, i.e.
  # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";

  sops.defaultSopsFile = inputs.self.outPath + "/nixos/hosts/common/secrets.yaml";
  sops.defaultSopsFormat = "yaml";

  # This will automatically import SSH keys as age keys
  # sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Import (automatically) all SSH keys, defined in the configuration, as age keys "for the target machines"
  sops.age.sshKeyPaths = map getKeyPath keys;

  # This is using an age key that is expected to already be in the filesystem
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  # This will generate a new key if the key specified above does not exist
  sops.age.generateKey = true;

  # NixOS system-wide home-manager configuration
  home-manager.sharedModules = [
    inputs.sops-nix.homeManagerModules.sops
  ];
}
