{
  config,
  pkgs,
  inputs,
  ...
}:
{
  # https://github.com/ViperML/nh
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 10";
    flake = "/home/mood/Projects/nix/nix-config"; # NOTE: you can't use `inputs.self.outPath` here, since that references the nix store path
  };
}
