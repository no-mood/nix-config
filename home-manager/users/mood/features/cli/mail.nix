{ lib, osConfig, ... }:
{
  accounts.email.accounts = {
    gmail = {
      address = osConfig.sensitive.gmail;
      userName = osConfig.sensitive.gmail;
      flavor = "gmail.com";
      realName = osConfig.sensitive.realName;
      primary = false;
      imap = {
        host = "imap.gmail.com";
        port = 993;
      };
      smtp = {
        host = "smtp.gmail.com";
        port = 465;
      };
      thunderbird = {
        enable = true;
      };
    };

    "studenti.polito" = {
      address = osConfig.sensitive.studentiPolitoEmail;
      userName = osConfig.sensitive.studentiPolitoEmail;
      realName = osConfig.sensitive.realName;
      primary = false;
      thunderbird.enable = true;
      imap = {
        host = "imap.studenti.polito.it";
        port = 993;
      };
      smtp = {
        host = "smtp.studenti.polito.it";
        port = 465;
      };
    };

    "polito" = {
      address = osConfig.sensitive.politoEmail;
      userName = osConfig.sensitive.politoEmail;
      realName = osConfig.sensitive.realName;
      primary = false;
      thunderbird = {
        enable = true;
        settings = id: {
          # OAuth method ID, check https://github.com/nix-community/home-manager/issues/4988
          "mail.server.server_${id}.authMethod" = 10;
          "mail.smtpserver.smtp_${id}.authMethod" = 10;
        };
      };
      imap = {
        host = "outlook.office365.com";
        port = 993;
      };
      smtp = {
        host = "smtp.office365.com";
        port = 587;
        tls.enable = true;
        tls.useStartTls = true;
      };
    };

    proton = {
      address = osConfig.sensitive.protonEmail;
      userName = osConfig.sensitive.protonEmail;
      realName = osConfig.sensitive.realName;
      primary = true;
      thunderbird.enable = true;
      imap = {
        host = "127.0.0.1";
        port = 2143; # default was 1143
        tls.enable = true;
        tls.useStartTls = true;
      };
      smtp = {
        host = "127.0.0.1";
        port = 2025; # default was 1025
        tls.enable = true;
        tls.useStartTls = true;
      };
    };
  };
}
