{pkgs, ...}: {
  home.packages = with pkgs; [
    vim # vimtutor is included
  ];
}
