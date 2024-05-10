{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  # Enable Cachix
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  # GDM display manager
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  # Hyprland from Flakes
  programs.hyprland.enable = true;
  programs.hyprland.package = inputs.hyprland.packages."${pkgs.system}".hyprland;

  # Electron apps
  environment.sessionVariables = {
    #WLR_NO_HARDWARE_CURSORS = "1";
    #NIXOS_OZONE_WL = "1";
    SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh"; #TODO remove this hard-coded line
    # another TODO: don't use keyring for ssh, switch to the new gcr or use keychain
    #SSH_AUTH_SOCK = "/run/user/${UID}/keyring/ssh";
    #SSH_AUTH_SOCK = "${builtins.getEnv "XDG_RUNTIME_DIR"}/keyring/ssh";
  };

  security.pam.services.gdm.enableGnomeKeyring = true; # TODO needed?
  networking.networkmanager.enable = true; # Enable networking

  environment.systemPackages = with pkgs; [
    networkmanagerapplet # network manager GUI
    brightnessctl
  ];

  services = {
    gvfs.enable = true; # Nautilus
    devmon.enable = true;
    udisks2.enable = true;
    upower.enable = true;
    power-profiles-daemon.enable = true;
    accounts-daemon.enable = true;
    gnome = {
      sushi.enable = true; # Sushi, a quick previewer for nautilus
      evolution-data-server.enable = true; # Gnome calendar
      glib-networking.enable = true;
      gnome-keyring.enable = true; # TODO needed, but for what
      gnome-online-accounts.enable = true;
    };
  };
  programs = {
    gnome-disks.enable = true;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts

    (nerdfonts.override {fonts = ["FiraCode" "DroidSansMono"];})
  ];

  # https://wiki.hyprland.org/Useful-Utilities/Must-have/#xdg-desktop-portal

  # TODO: needed?
  xdg.portal = {
    enable = true;
    # wlr.enable = true;
    extraPortals = with pkgs;
      lib.mkDefault [
        xdg-desktop-portal-gtk # gtk portal needed to make gtk apps happy
        # xdg-desktop-portal-wlr
      ];
  };

  # polkit and gnome-polkit
  security = {
    polkit.enable = true;
    # pam.services.ags = {};
  };
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
