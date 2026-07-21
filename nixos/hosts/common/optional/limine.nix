{
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.limine = {
    enable = true;
    secureBoot = {
      enable = true;
      autoGenerateKeys = true;
      autoEnrollKeys = {
        enable = true;
        extraArgs = [
          "--microsoft"
          "--firmware-builtin"
        ];
      };
    };
  };
}
