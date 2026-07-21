{
  config,
  ...
}:
{
  # Paths declared here are read by the NixOS restic service via custom.backupSources.user-data
  # in nixos/hosts/common/users/mood/default.nix
  services.restic.backups.local.paths = [
    "${config.home.homeDirectory}/Documents"
    "${config.home.homeDirectory}/Projects"
    "${config.home.homeDirectory}/Pictures"
    "${config.home.homeDirectory}/Music"
    "${config.home.homeDirectory}/Videos"
  ];
}
