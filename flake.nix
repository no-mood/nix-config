{
  description = "Mood's config, based on Misterio77";

  nixConfig = {
    extra-trusted-public-keys = [
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
    extra-substituters = [
      "https://devenv.cachix.org"
    ];
  };

  inputs = {
    # Using nixpkgs unstable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Nixpkgs stable
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    # Nixpkgs unstable, keeping this for compatibility
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft.url = "github:Infinidoge/nix-minecraft";

    nixarr.url = "github:rasmus-kirk/nixarr";
    catppuccin.url = "github:catppuccin/nix";

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:duxlabs-dev/dux-shell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      ...
    }@inputs:
    let
      # Supported systems for your flake packages, shell, etc.
      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
      ];
      # This is a function that generates an attribute by calling a function you
      # pass to it, with each system as an argument
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Your custom packages
      # Acessible through 'nix build', 'nix shell', etc
      packages = forAllSystems (
        system:
        import ./pkgs (
          import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          }
        )
      );
      # Formatter for your nix files, available through 'nix fmt'
      # Other options beside 'alejandra' include 'nixpkgs-fmt'
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      # Your custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild --flake .#your-hostname'
      nixosConfigurations = {
        tau = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ ./nixos/hosts/tau ];
        };
        lyr = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ ./nixos/hosts/lyr ];
        };
        dra = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ ./nixos/hosts/dra ];
        };
        installer = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [ ./nixos/hosts/installer ];
        };
      };

      # Everything buildable for each system, built by `nix-fast-build` in the pre-push hook.
      checks = forAllSystems (
        system:
        let
          inherit (nixpkgs) lib;
          prefix = p: lib.mapAttrs' (n: lib.nameValuePair "${p}-${n}");
          hosts = lib.filterAttrs (
            _: host: host.pkgs.stdenv.hostPlatform.system == system
          ) inputs.self.nixosConfigurations;
          packages = lib.filterAttrs (
            _: pkg: lib.meta.availableOn { inherit system; } pkg
          ) inputs.self.packages.${system};
        in
        prefix "nixos" (lib.mapAttrs (_: host: host.config.system.build.toplevel) hosts)
        // prefix "package" packages
        // prefix "devShell" inputs.self.devShells.${system}
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = inputs.devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              ./devenv.nix
            ]
            ++ (if builtins.pathExists ./devenv.local.nix then [ ./devenv.local.nix ] else [ ]);
          };
        }
      );
    };
}
