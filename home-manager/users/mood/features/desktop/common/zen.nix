{
  inputs,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  home.packages = with pkgs; [
    inputs.zen-browser.packages."${system}".default
  ];
}
