{
  config,
  osConfig,
  ...
}:
{
  imports = [
    ./global

    ./features/cli
    ./features/theming
    ./features/backup
  ];

  programs.opencode = {
    enable = true;
    web = {
      enable = true;
      extraArgs = [
        "--hostname"
        "127.0.0.1"
        "--port"
        "4096"
      ];
      environmentFile = osConfig.sops.templates.opencode.path;
    };
  };

  # The module does not set PATH for the user service.
  systemd.user.services.opencode-web.Service = {
    Environment = [ "PATH=${config.home.path}/bin:${osConfig.system.path}/bin" ];
    MemoryHigh = "60%";
    MemoryMax = "75%";
    NoNewPrivileges = true;
  };

}
