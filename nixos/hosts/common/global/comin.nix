{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.comin.nixosModules.comin ];

  sops.secrets."comin/github-token" = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  services.comin = {
    enable = true;
    package = inputs.comin.packages.${pkgs.stdenv.hostPlatform.system}.default;

    remotes = [
      {
        name = "origin";
        url = "https://github.com/no-mood/nix-config-private.git";
        auth = {
          access_token_path = config.sops.secrets."comin/github-token".path;
        };
        branches = {
          main = {
            name = "main";
            operation = "switch";
          };
          testing = {
            name = "testing-${config.networking.hostName}";
            operation = "test";
          };
        };
      }
    ];
  };
}
