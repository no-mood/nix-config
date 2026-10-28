{
  config,
  inputs,
  ...
}:

let
  user = "mood";
  host = "127.0.0.1";
  port = 4096;
in
{
  # The OpenCode server itself runs as a systemd --user service, defined in
  # home-manager (home-manager/users/mood/features/opencode-server.nix).
  # Here we only manage the secrets and the reverse proxy.

  sops.secrets = {
    "opencode/server-password" = {
      sopsFile = inputs.self.outPath + "/nixos/hosts/${config.networking.hostName}/secrets.yaml";
      owner = user;
    };
    "opencode/server-username" = {
      sopsFile = inputs.self.outPath + "/nixos/hosts/${config.networking.hostName}/secrets.yaml";
      owner = user;
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
    reverse_proxy ${host}:${toString port}
  '';
}
