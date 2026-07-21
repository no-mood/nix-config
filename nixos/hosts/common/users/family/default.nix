{
  config,
  pkgs,
  ...
}:
# https://github.com/Misterio77/nix-config/blob/a735a52670dbe344ab4e0e274b0fd9b1b709c0ed/hosts/common/users/gabriel/default.nix#L7
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  user = "family";
in
{
  users.users.${user} = {
    isNormalUser = true;
    hashedPassword = "$6$SXv5lhiWHX6iYRZY$UbVc8cfs9gTjsmGnrIXHsyonT.2deR./MR95/RBL9sYC6nno4uVPIDMoSmUeC0fRS0pAT.P4PqagDVQRL7HSg/";
    description = "${user}";
    shell = pkgs.fish;
    extraGroups = ifTheyExist [
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFxbhFz7wWM0ohZry834Xk1VRRTw91h4dFW2kYALVWGG mood@tau"
    ];
    packages = with pkgs; [
      firefox
      brave
      vlc
      thunderbird
      onlyoffice-desktopeditors
      gimp3
      telegram-desktop
      element-desktop
      spotify
    ];
  };
}
