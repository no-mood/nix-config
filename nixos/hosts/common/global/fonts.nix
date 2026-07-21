{ pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    packages = with pkgs; [
      dejavu_fonts
      nerd-fonts.jetbrains-mono
      noto-fonts-color-emoji
    ];

    fontconfig = {
      defaultFonts = {
        serif = [
          "DejaVu Serif"
        ];
        sansSerif = [
          "DejaVu Sans"
        ];
        monospace = [
          "JetBrainsMono Nerd Font Mono"
        ];
      };
    };
  };
}
