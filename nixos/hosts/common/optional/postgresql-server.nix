{ lib, config, ... }:
{
  services.postgresql = {
    enable = true;
    # Required for pgbackrest WAL archiving (not set automatically by the pgbackrest module)
    settings.wal_level = "replica";
  };

  # pgbackrest: hot backup (no postgres downtime), WAL archiving, PITR, retention.
  # When services.postgresql.enable = true the module auto-sets:
  #   archive_command = "pgbackrest --stanza=default archive-push %p"
  #   archive_mode    = "on"
  #   identMap / initdbArgs / user/group wiring
  # Restore: sudo -u postgres pgbackrest --stanza=default restore
  services.pgbackrest = {
    enable = true;
    repos.localhost.path = "/var/backup/pgbackrest";
    stanzas.default.jobs = {
      weekly = {
        schedule = "Sun 02:00";
        type = "full";
      };
      daily = {
        schedule = "Mon-Sat 02:00";
        type = "diff";
      };
    };
  };

  # Restic backs up the pgbackrest repo (complete pg backups + WAL archive, already
  # consistent at file level) — no need to stop postgres.
  services.restic.backups = lib.genAttrs [ "local" "hetzner" ] (_: {
    paths = [ config.services.pgbackrest.repos.localhost.path ];
  });
}
