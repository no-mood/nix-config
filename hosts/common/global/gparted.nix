{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gparted
    xorg.xhost
  ];
}
