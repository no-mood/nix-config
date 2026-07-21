{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.opencode-server;
in
{
  options.services.opencode-server = {
    enable = lib.mkEnableOption "OpenCode web server";

    package = lib.mkPackageOption pkgs "opencode" { };

    user = lib.mkOption {
      type = lib.types.str;
      default = "opencode";
      description = "User account under which the OpenCode server runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "opencode";
      description = "Group under which the OpenCode server runs.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address on which the OpenCode server listens.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4096;
      description = "TCP port on which the OpenCode server listens.";
    };

    workspace = lib.mkOption {
      type = lib.types.str;
      default = config.users.users.${cfg.user}.home;
      defaultText = lib.literalExpression "config.users.users.\${config.services.opencode-server.user}.home";
      description = "Directory containing the projects accessible to OpenCode.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Environment file containing secrets and other variables for OpenCode.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Environment variables passed to the OpenCode service. Do not use this option for secrets.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional command-line arguments passed to OpenCode.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the OpenCode server port in the firewall.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.mkIf (cfg.user == "opencode") {
      opencode = {
        isSystemUser = true;
        group = cfg.group;
        home = "/var/lib/opencode";
        createHome = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == "opencode") {
      opencode = { };
    };

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;

    systemd.services.opencode-server = {
      description = "OpenCode web server";
      documentation = [ "https://opencode.ai/docs/web/" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = cfg.environment // {
        HOME = config.users.users.${cfg.user}.home;
      };

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.workspace;
        ExecStart = lib.escapeShellArgs (
          [
            (lib.getExe cfg.package)
            "serve"
            "--hostname"
            cfg.host
            "--port"
            (toString cfg.port)
          ]
          ++ cfg.extraArgs
        );
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
      }
      // lib.optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      };
    };
  };
}
