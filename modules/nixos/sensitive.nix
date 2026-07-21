{ lib, ... }:
{
  options.sensitive = {
    myDomain = lib.mkOption {
      type = lib.types.str;
      default = "example.com";
      description = "The domain name for services and virtual hosts.";
    };

    realName = lib.mkOption {
      type = lib.types.str;
      default = "User";
      description = "Real name of the main user.";
    };

    gmail = lib.mkOption {
      type = lib.types.str;
      default = "user@example.com";
      description = "Gmail address.";
    };

    studentiPolitoEmail = lib.mkOption {
      type = lib.types.str;
      default = "student@example.com";
      description = "University email (studenti.polito.it).";
    };

    politoEmail = lib.mkOption {
      type = lib.types.str;
      default = "staff@example.com";
      description = "Polito staff email.";
    };

    devEmail = lib.mkOption {
      type = lib.types.str;
      default = "dev@example.com";
      description = "Development/public email (git, commits).";
    };

    protonEmail = lib.mkOption {
      type = lib.types.str;
      default = "user@proton.me";
      description = "Proton Mail address.";
    };

    sshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "SSH public keys for the main user.";
    };

    syncthingDevices = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Syncthing device IDs keyed by hostname.";
    };
  };
}
