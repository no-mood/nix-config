{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Enable Fish
  programs.zellij = {
    enable = true;
    settings = { };
  };
}
