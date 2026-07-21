{ config, pkgs, ... }:
let
  services = [
    "ollama.service"
  ];
in
{
  services.ollama = {
    enable = true;
    openFirewall = true;
    host = "127.0.0.1";
    port = 11434;
    loadModels = [ ]; # Optional: preload models, see https://ollama.com/library
    user = "ollama";
    group = "ollama";
  };

  services.open-webui = {
    enable = true;
    openFirewall = true;
    host = "127.0.0.1";
    port = 8080;
    environment = {
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      OLLAMA_API_BASE_URL = "http://127.0.0.1:${toString config.services.ollama.port}/api";
      OLLAMA_BASE_URL = "http://127.0.0.1:${toString config.services.ollama.port}";
    };
  };

  services.caddy = {
    virtualHosts."open-webui.${config.sensitive.myDomain}".extraConfig = ''
      reverse_proxy 127.0.0.1:${toString config.services.open-webui.port}
    '';
  };

  environment.systemPackages = with pkgs; [
    oterm
  ];

  services.restic.backups = lib.genAttrs [ "local" "hetzner" ] (_: {
    paths = [
      config.services.ollama.home # Ollama models and configuration
    ];
  });

  # Configure restic backups to stop Ollama while running
  systemd.services = lib.genAttrs [ "restic-backups-local" "restic-backups-hetzner" ] (_: {
    unitConfig = {
      Conflicts = services;
      After = services;
      OnFailure = services;
      OnSuccess = services;
    };
  });
}
