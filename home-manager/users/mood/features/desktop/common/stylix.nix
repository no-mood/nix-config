{
  config,
  lib,
  options,
  ...
}:
{
  config = lib.optionalAttrs (options ? stylix) {
    # Handled in the nixos module
    stylix = {
      targets =
        builtins.listToAttrs (
          map
            (name: {
              name = name;
              value = {
                profileNames = [ "${config.home.username}" ];
              };
            })
            [
              "firefox"
              "vscode"
            ]
        )
        // {
          gtksourceview.enable = false; # Avoid cache miss in fractal
        };
    };
  };

}
