{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      AddKeysToAgent = "yes";
      ServerAliveInterval = 120;
      ServerAliveCountMax = 3;
      TCPKeepAlive = "yes";
    };
  };

  services.ssh-agent.enable = true;
}
