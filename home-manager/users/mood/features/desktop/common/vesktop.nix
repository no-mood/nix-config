{ config, ... }:
{
  programs.vesktop = {
    enable = true;
    vencord.useSystem = true;
    settings = {
      autoUpdate = false;
      autoUpdateNotification = false;
      notifyAboutUpdates = false;
      useQuickCss = true;
      disableMinSize = true;
      plugins = {
        MessageLogger = {
          enabled = true;
          ignoreSelf = true;
        };
        FakeNitro.enabled = true;
      };
    };
  };
}
