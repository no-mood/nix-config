{
  nixpkgs.config.cudaSupport = true; # Set this to false for the first build, to avoid compiling.

  # CUDA cache
  #  Warning: You need to rebuild your system at least once after adding the cache, before it can be used.
  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
