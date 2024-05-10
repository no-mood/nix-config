{pkgs, ...}: {
  imports = [
    # ./pkg.nix
  ];

  home.packages = with pkgs; [
    # pkg or unstable.pkg

    # Chat
    telegram-desktop
    discord

    # Music
    spotify

    # Video
    vlc

    # Graphics
    inkscape-with-extensions

    # Recording
    obs-studio
    ffmpeg

    # Torrent
    fragments
  ];
}
