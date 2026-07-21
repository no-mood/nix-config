{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
# https://github.com/Misterio77/nix-config/blob/a735a52670dbe344ab4e0e274b0fd9b1b709c0ed/hosts/common/users/gabriel/default.nix#L7
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  user = "mood";
in
{
  imports = [
    ./syncthing.nix
  ];

  sops.secrets."user/${user}/hashedPassword" = {
    # sopsFile = ../../secrets.yaml;
    neededForUsers = true;
  };

  users.mutableUsers = false;

  users.users.${user} = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets."user/${user}/hashedPassword".path;
    description = user;
    shell = pkgs.fish;
    extraGroups = ifTheyExist [
      "networkmanager"
      "wheel"
      "libvirtd"
      "docker"
      "wireshark"
      "gamemode"
      "i2c"
      "minecraft" # For the minecraft server
      "jellyfin" # For the jellyfin server
      "immich" # For the immich server
      "ollama" # For the ollama server
      "calibre-server" # For the calibre-server
      "calibre-web" # For the calibre-web server
      "calibre" # For the calibre group
      "docker"
    ];
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      # Add your SSH public key(s) here, if you plan on using SSH to connect
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxbhFz7wWM0ohZry834Xk1VRRTw91h4dFW2kYALVWGG mood@tau"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjQ5EB8Uf/oxL+hqK7sgdlPAAw11Cvb5SoPDRgn20VF mood@dra"
    ];
  };

  # Handle home-manager in the user module
  home-manager.users.${user} =
    import "${inputs.self}/home-manager/users/${user}/${config.networking.hostName}.nix";

  # User data backup source — paths declared in home-manager features/backup/restic.nix
  custom.backupSources.user-data = {
    paths = config.home-manager.users.${user}.services.restic.backups.local.paths;
  };

}
