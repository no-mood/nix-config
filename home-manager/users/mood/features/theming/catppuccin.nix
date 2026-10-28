{
  options,
  lib,
  osConfig,
  ...
}:
{
  config = lib.optionalAttrs (options ? catppuccin) {
    catppuccin = {
      enable = osConfig.catppuccin.enable;
      autoEnable = osConfig.catppuccin.autoEnable;
      flavor = lib.mkDefault osConfig.catppuccin.flavor;
      accent = lib.mkDefault osConfig.catppuccin.accent;
    };
  };

}
