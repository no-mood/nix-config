{pkgs, ...}: {
  imports = [
    # ./pkg.nix
  ];

  home.packages = with pkgs; [
    # pkg or unstable.pkg
    # toybox
    steam-run

    wireshark
    nmap

    iw
    iperf
    aircrack-ng

    # ghidra

    # binwalk
    # xxd
    # exiftool
    # stegsolve
  ];
}
