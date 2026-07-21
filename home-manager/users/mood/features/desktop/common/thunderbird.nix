{ config, ... }:
{
  programs.thunderbird = {
    enable = true;
    profiles."${config.home.username}" = {
      isDefault = true;
      # settings = {};
      userChrome = "";
      userContent = "";
    };
  };
}
