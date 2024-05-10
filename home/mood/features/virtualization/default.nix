{pkgs, ...}: {
  imports = [
    # ./pkg.nix
  ];

  home.packages = with pkgs; [
    # pkg or unstable.pkg
    qemu
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
