# Backport of nixpkgs 8d96d132d1cf ("khal: Fix build"): the separate "man" Sphinx builder
# does not produce the man output. Remove once it reaches nixos-unstable.
_final: prev: {
  khal = prev.khal.overrideAttrs {
    sphinxBuilders = [ "html man" ];
  };
}
