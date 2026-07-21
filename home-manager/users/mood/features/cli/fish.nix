{
  config,
  osConfig,
  pkgs,
  ...
}:
{
  # Install packages needed for custom greeting
  home.packages = with pkgs; [
    krabby
    fortune
  ];

  # Enable Fish
  programs.fish = {
    enable = osConfig.programs.fish.enable; # must be enabled system-wide

    interactiveShellInit = ''
      # Define custom fish_greeting function
      function fish_greeting
        echo
        ${pkgs.krabby}/bin/krabby random 1
        echo
        ${pkgs.fortune}/bin/fortune computers
        echo
      end
      devenv hook fish | source
    '';
  };
  home.shell.enableFishIntegration = true; # Enable Fish integration for Home Manager
}
