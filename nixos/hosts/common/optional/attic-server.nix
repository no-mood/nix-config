{
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.attic.nixosModules.atticd ];

  sops.secrets."attic/server-token-rs256-secret-base64" = {
    sopsFile = inputs.self.outPath + "/nixos/hosts/lyr/secrets.yaml";
    owner = "root";
    group = "root";
    mode = "0400";
    restartUnits = [ "atticd.service" ];
  };

  sops.templates.atticd-environment = {
    content = "ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=${
      config.sops.placeholder."attic/server-token-rs256-secret-base64"
    }";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  services.atticd = {
    enable = true;
    environmentFile = config.sops.templates.atticd-environment.path;
    settings = {
      listen = "127.0.0.1:8080";
      api-endpoint = "https://cache.${config.sensitive.myDomain}/";
      jwt = { };
      database.url = "sqlite:///var/lib/atticd/server.db?mode=rwc";
      storage = {
        type = "local";
        path = "/var/lib/atticd/storage";
      };
      chunking = {
        nar-size-threshold = 64 * 1024;
        min-size = 16 * 1024;
        avg-size = 64 * 1024;
        max-size = 256 * 1024;
      };
    };
  };

  services.caddy.virtualHosts."cache.${config.sensitive.myDomain}".extraConfig = ''
    reverse_proxy 127.0.0.1:8080
  '';
}
