{
  pkgs,
  lib,
  ...
}:
{
  # Minimal gaming user
  users.users.gaming =
    let
      factorio = pkgs.factorio.override {
        username = "xmood";
        token = "04e0e312e76549458060956b9af76d";
      };
    in
    {
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
        # factorio
        (heroic.override {
          extraPkgs = pkgs: [
            gamescope
            winetricks
            wineWow64Packages.waylandFull
          ];
        })
        prismlauncher
        lutris
        bottles
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
  };

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
