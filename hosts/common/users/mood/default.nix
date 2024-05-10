{
  config,
  pkgs,
  ...
}:
# IDK but added following https://github.com/Misterio77/nix-config/blob/2cef278896e419c90e8df94127905a14ff88d058/hosts/common/users/misterio/default.nix
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mood = {
    isNormalUser = true;
    description = "mood";
    shell = pkgs.zsh;
    extraGroups = ["networkmanager" "wheel" "libvirtd" "wireshark"];
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
    ];
  };
}
