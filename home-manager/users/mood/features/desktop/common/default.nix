{ pkgs, ... }:
{
  imports = [
    ./wayland-wm

    ./stylix.nix
    ./catppuccin.nix

    # System
    ./gtk.nix
    ./gnome-apps.nix

    # Browser
    ./firefox.nix
    ./zen.nix
    ./chrome.nix
    ./brave.nix
    ./tor.nix

    # IDE
    ./vscode.nix
    #./jetbrains.nix
    ./zed.nix

    ./zathura.nix
    ./thunderbird.nix
    ./proton.nix
    ./virt-manager.nix
    ./vesktop.nix
  ];

  home.packages = with pkgs; [
    # pkg or unstable.pkg

    # Chat
    telegram-desktop
    slack
    element-desktop
    fractal
    signal-desktop

    # Music
    spotify

    # Video
    vlc

    # Graphics
    gimp3
    inkscape-with-extensions

    # Recording
    obs-studio

    # Torrent
    fragments

    # Office suit
    onlyoffice-desktopeditors

    # VPN
    wireguard-tools

    # For logitech mice, services enabled in services
    piper

    # Remote desktop
    #rustdesk-flutter
    remmina

    zotero
    obsidian
  ];
}
