{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    mupdf # Textual PDF previews
    poppler_utils # PDF image previews
  ];

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
