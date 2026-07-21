{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Broadwell (2014) or newer processors. LIBVA_DRIVER_NAME=iHD
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  }; # Optionally, set the environment variable

  services.xserver.videoDrivers = [ "modesetting" ]; # https://nixos.org/manual/nixos/stable/#sec-x11--graphics-cards-intel
}
