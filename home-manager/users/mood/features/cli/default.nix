{ pkgs, ... }:
{
  imports = [
    # ./pkg.nix
    ./git.nix
    # ./zsh.nix
    ./fish.nix
    ./starship.nix
    ./bash.nix
    ./nvim.nix
    ./helix.nix
    ./direnv.nix
    ./ssh.nix
    #./ranger.nix
    ./yazi.nix
    ./modern-unix.nix
    ./zellij.nix
    ./ncspot.nix
    ./mail.nix
    ./ai.nix
  ];

  home.packages = with pkgs; [
    # pkg or unstable.pkg

    # Must have
    wget
    curl
    fastfetch
    btop
    zip
    ffmpeg_6

    # Fun
    cmatrix
    cbonsai
    cowsay

    # File manager
    mc
    ranger

    # Coding
    devenv

    # Utilities
    ncdu # disk usage analyser
    wakeonlan
    poppler-utils

    # Sensors
    lm_sensors
  ];
}
