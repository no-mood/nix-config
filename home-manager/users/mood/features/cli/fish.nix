{
  config,
  osConfig,
  pkgs,
  ...
}:
{
  # Install packages needed for custom greeting
  home.packages = with pkgs; [
    fortune
  ];

  # Enable Fish
  programs.fish = {
    enable = osConfig.programs.fish.enable; # must be enabled system-wide

    interactiveShellInit = ''
      # Define custom fish_greeting function
      function fish_greeting
        ${pkgs.fastfetch}/bin/fastfetch
        echo
        ${pkgs.fortune}/bin/fortune computers
      end
      devenv hook fish | source
    '';
  };
  home.shell.enableFishIntegration = true; # Enable Fish integration for Home Manager
}
