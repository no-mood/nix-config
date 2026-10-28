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

    # Evaluate and build all flake checks (hosts, packages, dev shell)
    nix-fast-build = {
      enable = true;
      name = "Build flake checks";
      package = pkgs.nix-fast-build;
      entry = "${lib.getExe pkgs.nix-fast-build} --flake .#checks.${pkgs.stdenv.hostPlatform.system} --skip-cached --impure --eval-workers 1 --fail-fast";
      files = "\\.(nix)$|^flake\\.lock$"; # Files ending with .nix or flake.lock
      excludes = [ "^devenv\\." ]; # Exclude devenv.* files
      stages = [ "pre-push" ];
      language = "system";
      pass_filenames = false;
    };

    # Block pushing the public branch if the pushed commit still carries the
    # files sync-public-repo strips (sensitive.nix, secrets, host keys).
    check-sensitive-on-public = {
      enable = true;
      name = "Block sensitive data on public branch";
      entry = toString (
        pkgs.writeShellScript "check-sensitive-on-public" ''
          [ "''${PRE_COMMIT_REMOTE_BRANCH##*/}" = public ] || exit 0
          leaked=$(git ls-tree -r --name-only "''${PRE_COMMIT_TO_REF:-HEAD}" \
            | grep -E '^nixos/hosts/common/global/sensitive\.nix$|(^|/)secrets\.yaml$|(^|/)ssh_host_[^/]*\.pub$' || true)
          if [ -n "$leaked" ]; then
            echo "ERROR: the public branch would publish:"
            echo "$leaked"
            echo "Update it with 'sync-public-repo' instead."
            exit 1
          fi
        ''
      );
      stages = [ "pre-push" ];
      language = "system";
      pass_filenames = false;
    };
  };

  # See full reference at https://devenv.sh/reference/options/
}
