{
  inputs,
  osConfig,
  ...
}:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # configure options
  programs.noctalia-shell = {
    enable = osConfig.programs.niri.enable;

    # Enable niri-overview-launcher plugin
    plugins = {
      sources = [
        {
          enabled = true;
          name = "Official Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = {
        niri-overview-launcher = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
      version = 2;
    };

    # As the docs say, "this may also be a string or a path to a JSON file."
    settings = ./noctalia-settings.json;
    # You can import a nix file, by using a JSON-to-nix online converter to convert into nix format.
    # https://json-to-nix.pages.dev/
    # settings = import ./noctalia-settings.nix;
  };
}
