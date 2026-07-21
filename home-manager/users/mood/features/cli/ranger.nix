{
  config,
  pkgs,
  ...
}:
{
  # Enable ranger
  programs.ranger = {
    enable = true;
    aliases = {
      e = "edit";
      filter = "scout -prts";
      setl = "setlocal";
    };
  };
}
