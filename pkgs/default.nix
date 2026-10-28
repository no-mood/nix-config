# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  epic-games-launcher = pkgs.callPackage ./epic-games-launcher { };
  # example = pkgs.callPackage ./example { };
}
