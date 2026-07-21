{
  config,
  inputs,
  outputs,
  ...
}:

let
  inherit (config.services.opencode-server) user;
in
{
  imports = [ outputs.nixosModules.opencode-server ];

  services.opencode-server = {
    enable = true;
    user = "mood";
    group = "users";
    host = "127.0.0.1";
    port = 4096;
    environmentFile = config.sops.templates.opencode.path;
  };

  sops.secrets = {
    "opencode/server-password" = {
      sopsFile = inputs.self.outPath + "/nixos/hosts/${config.networking.hostName}/secrets.yaml";
      owner = user;
      restartUnits = [ "opencode-server.service" ];
    };
    "opencode/server-username" = {
      sopsFile = inputs.self.outPath + "/nixos/hosts/${config.networking.hostName}/secrets.yaml";
      owner = user;
      restartUnits = [ "opencode-server.service" ];
    };
  };

  sops.templates.opencode = {
    content = ''
      OPENCODE_SERVER_PASSWORD=${config.sops.placeholder."opencode/server-password"}
      OPENCODE_SERVER_USERNAME=${config.sops.placeholder."opencode/server-username"}
    '';
    owner = user;
  };

  services.caddy.virtualHosts."opencode.${config.sensitive.myDomain}".extraConfig = ''
    reverse_proxy ${config.services.opencode-server.host}:${toString config.services.opencode-server.port}
  '';
}
