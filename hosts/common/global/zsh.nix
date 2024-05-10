{...}: {
  # Zsh has to be enabled on a system-level
  # so it's enabled here and configured on home-manager
  # see
  # https://www.reddit.com/r/NixOS/comments/z16mt8/comment/ix9r4b2/?utm_source=share&utm_medium=web2x&context=3
  programs.zsh.enable = true;
}
