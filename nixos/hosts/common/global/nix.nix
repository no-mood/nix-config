{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      # https://wiki.nixos.org/wiki/Storage_optimization
      gc = {
        automatic = false; # now using nh for this
        dates = "weekly";
        options = "--delete-older-than 8d";
      };

      # To free up to 20 GiB whenever there is less than 1GiB left
      extraOptions = ''
        min-free = ${toString (1 * 1024 * 1024 * 1024)}
        max-free = ${toString (20 * 1024 * 1024 * 1024)}
      '';

      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Deduplicate and optimize nix store
        auto-optimise-store = false; # using periodic optimization

        trusted-users = [
          "root"
          "@wheel" # this was added for devenv, instead of adding every user
        ];
      };

      optimise = {
        automatic = true;
        dates = [ "20:30" ]; # Time
      };

      # Opinionated: disable channels
      channel.enable = false;

      # Opinionated: make flake registry and nix path match flake inputs. Taken from https://github.com/Misterio77/nix-starter-configs/blob/cd2634edb7742a5b4bbf6520a2403c22be7013c6/standard/nixos/configuration.nix#L66
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };
}
