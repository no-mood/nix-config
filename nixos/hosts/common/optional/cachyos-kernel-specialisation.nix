{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # CachyOS kernel as an optional boot entry
  specialisation.cachyos.configuration =
    let
      cachyosKernels = inputs.nix-cachyos-kernel.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      system.nixos.tags = [ "cachyos" ];
      boot.kernelPackages = lib.mkForce cachyosKernels.linuxPackages-cachyos-bore-x86_64-v3;
    };
}
