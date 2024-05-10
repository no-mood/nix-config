{pkgs, ...}: {
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      opener = {
      };

      open.rules = [
      ];
    };
  };
}
