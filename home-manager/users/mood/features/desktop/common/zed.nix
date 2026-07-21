{
  inputs,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    zed-editor
  ];

  # TODO use the HM module?
}
