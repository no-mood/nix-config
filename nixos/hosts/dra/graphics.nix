{ ... }:
{
  # AMD RX 9060 XT — amdgpu driver is built into the kernel, no extra setup needed.
  # https://wiki.nixos.org/wiki/AMD_GPU
  nixpkgs.config.rocmSupport = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
