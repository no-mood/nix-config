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
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        serverAliveInterval = 120;
        serverAliveCountMax = 3;
        extraOptions = {
          TCPKeepAlive = "yes";
        };
      };
    };
  };

  services.ssh-agent.enable = true;
}
