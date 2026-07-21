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
      flavor = lib.mkDefault osConfig.catppuccin.flavor;
      accent = lib.mkDefault osConfig.catppuccin.accent;
    };
  };

}
