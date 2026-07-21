{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = with pkgs; [
    git
    openssh
    git-filter-repo

    sops
    ssh-to-age
    gnupg
    age
    disko
    nixos-anywhere
  ];

  # https://devenv.sh/languages/
  languages.nix = {
    enable = true;
    lsp.package = pkgs.nixd;
  };

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  scripts = {
    deploy-host.exec = builtins.readFile ./scripts/deploy-host.sh;
    build-iso.exec = builtins.readFile ./scripts/build-iso.sh;
    sync-public-repo = {
      exec = builtins.readFile ./scripts/sync-public-repo.sh;
      packages = [ pkgs.git-filter-repo ];
      description = "Sync public branch: strip sensitive.nix, secrets.yaml, host keys and push";
    };
  };

  enterShell = ''
    echo "nix shell"
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
  '';

  # https://devenv.sh/git-hooks/
  git-hooks.hooks = {
    check-merge-conflicts.enable = true;
    trim-trailing-whitespace.enable = true;
    nixfmt.enable = true;

    # Check flake syntax and evaluation
    nix-flake-check = {
      enable = true;
      name = "Nix flake check";
      entry = "${pkgs.nix}/bin/nix flake check --impure";
      files = "\\.(nix)$|^flake\\.lock$"; # Files ending with .nix or flake.lock
      excludes = [ "^devenv\\." ]; # Exclude devenv.* files
      language = "system";
      pass_filenames = false;
    };

    # Block push to public branch if sensitive.nix contains real values
    check-sensitive-on-public = {
      enable = true;
      name = "Block sensitive data on public branch";
      entry = toString (
        pkgs.writeShellScript "check-sensitive-on-public" ''
          while read local_ref local_sha remote_ref remote_sha; do
            branch=$(basename "$remote_ref")
            if [ "$branch" != "public" ]; then continue; fi
            if grep -qF 'giovanninicosia.dev' nixos/hosts/common/global/sensitive.nix 2>/dev/null; then
              echo "ERROR: sensitive.nix contains real values. Run 'bash scripts/sync-public.sh' first."
              exit 1
            fi
          done
        ''
      );
      stages = [ "pre-push" ];
      language = "system";
      pass_filenames = false;
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
