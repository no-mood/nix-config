{
  config,
  pkgs,
  ...
}: {
  # Enable bash
  programs.bash = {
    enable = true;
  };
}
