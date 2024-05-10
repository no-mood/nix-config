{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    hyprnome
  ];

  wayland.windowManager.hyprland = {
    enable = true; # TODO check if this works correctly, previous was true
    systemd = {
      enable = true;
      variables = ["--all"];
    };
    plugins = [
      # inputs.hyprland-plugins.packages."${pkgs.system}".borders-plus-plus
      # inputs.hyprland-plugins.packages.${pkgs.system}.hyprexpo
    ];

    settings = {
      exec-once = with pkgs; [
        #"${polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "${gnome.gnome-keyring}/bin/gnome-keyring-daemon --start --components=secrets,ssh"
        "${config.programs.ags.package}/bin/ags -b hypr"
        #"${hyprpaper}/bin/hyprpaper"
        "${swww}/bin/swww init"
      ];
      exec = with pkgs; [
        "${swww}/bin/swww img ${config.rice.wallpaper} --transition-type wipe --transition-step 1 --transition-fps 60"
      ];

      # plugin.hyprexpo = {
      #   columns = 3;
      #   gap_size = 5;
      #   bg_col = "rgb(111111)";
      #   workspace_method = "first 1"; # [center/first] [workspace] e.g. first 1 or center m+1
      #   enable_gesture = true; # laptop touchpad, 4 fingers
      #   gesture_distance = 300; # how far is the "max"
      #   gesture_positive = false; # positive = swipe down. Negative = swipe up.
      # };

      bind = let
        binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
      in [
        # "SUPER, TAB, hyprexpo:expo, toggle"
      ];
    };

    # This is order sensitive, so it has to come here.
    extraConfig = ''
      env = LIBVA_DRIVER_NAME,nvidia
      env = XDG_SESSION_TYPE,wayland
      env = GBM_BACKEND,nvidia-drm # remove if crashes in Firefox
      #env = __GLX_VENDOR_LIBRARY_NAME,nvidia # discord crashes
      env = WLR_NO_HARDWARE_CURSORS,1

      env = NIXOS_OZONE_WL,1

      xwayland {
        force_zero_scaling = true
      }
      ${builtins.readFile ./config/default_config.conf}

    '';
  };
}
