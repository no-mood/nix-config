{ pkgs, ... }:
{
  # Taken from
  # https://github.com/johnalanwoods/maintained-modern-unix

  home.packages = with pkgs; [
    tldr

    dust
    ripgrep-all
    pdfgrep
    sd
    httpie
  ];

  programs = {
    # zoxide: A smarter cd command for your terminal
    zoxide = {
      enable = true;
    };

    # bat: A cat clone with syntax highlighting and Git integration
    bat = {
      enable = true;
    };

    # eza: A modern replacement for ls
    eza = {
      enable = true;
    };

    # fd: A simple, fast and user-friendly alternative to find
    fd = {
      enable = true;
    };

    # lsd: The next gen ls command
    lsd = {
      enable = true;
    };

    # ripgrep: A line-oriented search tool that recursively searches your current directory for a regex pattern
    ripgrep = {
      enable = true;
    };

    # fzf: A general-purpose command-line fuzzy finder
    fzf = {
      enable = true;
    };

    # navi: An interactive cheatsheet tool for the command-line
    navi = {
      enable = true;
      settings = {
      };
    };
  };
}
