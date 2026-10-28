{
  pkgs,
  lib,
  ...
}:
{
  # Minimal gaming user
  users.users.gaming = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$obtIs4Ft1bT1B6KyxPpTq/$qwV5SaDoa/LLwPGfIoXL2dQg.8j7jftd5IzEx4HLsiD";
    extraGroups = [
      "networkmanager"
      "gamemode"
      "audio"
      "video"
    ];
    packages = with pkgs; [
      firefox
      (heroic.override {
        extraPkgs = pkgs: [
          gamescope
          winetricks
          wineWow64Packages.waylandFull
        ];
      })
      epic-games-launcher
      prismlauncher
      lutris
      bottles
      vesktop
    ];
  };

  programs.gamemode.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    extraPackages = with pkgs; [
      mangohud
    ];
    protontricks.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # Xbox controllers over Bluetooth; wired ones use the in-kernel xpad driver.
  hardware.xpadneo.enable = true;

  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--rt" # Real-time priority
        "--force-grab-cursor" # Fix cursor issues
        "-f" # Fullscreen
        "-e" # Steam integration
        "--mangoapp" # Use mangoapp instead of mangohud overlay
      ];
    };
    steam.gamescopeSession.enable = true;
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
    ];

  environment.systemPackages = with pkgs; [
    mangohud
  ];
}
