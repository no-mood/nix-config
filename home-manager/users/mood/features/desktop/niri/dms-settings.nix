# Dux Shell settings (~/.config/dms/settings.json).
# Export current values with: dms ipc call settings dump
{
  acLockTimeout = 900;
  acMonitorTimeout = 900;
  acSuspendTimeout = 1200;
  appIdSubstitutions = [ ];
  avatarRing = "outline";
  barConfigs = [
    {
      autoHide = false;
      autoHideDelay = 250;
      borderColor = "surfaceText";
      borderEnabled = false;
      borderOpacity = 1;
      borderThickness = 1;
      bottomGap = 0;
      centerWidgets = [
        "music"
        "clock"
        "weather"
      ];
      clickThrough = false;
      enabled = true;
      followInterfaceStyle = true;
      fontScale = 1;
      gothCornerRadiusOverride = false;
      gothCornerRadiusValue = 12;
      gothCornersEnabled = false;
      hoverPopouts = false;
      iconScale = 1;
      id = "default";
      innerPadding = 4;
      leftWidgets = [
        {
          enabled = true;
          id = "launcherButton";
          launcherLogoMode = "os";
        }
        {
          enabled = true;
          id = "workspaceSwitcher";
          showWorkspaceApps = true;
          showWorkspaceName = true;
          workspaceFollowFocus = true;
        }
        "focusedWindow"
      ];
      maximizeDetection = true;
      maximizeWidgetIcons = false;
      maximizeWidgetText = false;
      name = "Main Bar";
      noBackground = false;
      openOnOverview = false;
      popupGapsAuto = true;
      popupGapsManual = 4;
      position = 0;
      rightWidgets = [
        {
          enabled = true;
          id = "systemTray";
        }
        {
          enabled = true;
          id = "clipboard";
        }
        {
          enabled = true;
          id = "cpuUsage";
          minimumWidth = true;
        }
        {
          enabled = true;
          id = "notificationButton";
        }
        {
          enabled = true;
          id = "battery";
        }
        {
          enabled = true;
          id = "privacyIndicator";
        }
        {
          enabled = true;
          id = "controlCenterButton";
          showMicPercent = true;
        }
      ];
      screenPreferences = [ "all" ];
      scrollEnabled = true;
      scrollXBehavior = "focusWindow";
      scrollYBehavior = "workspace";
      shadowColorMode = "text";
      shadowCustomColor = "#000000";
      shadowIntensity = 0;
      shadowOpacity = 60;
      showOnLastDisplay = true;
      showOnWindowsOpen = false;
      spacing = 4;
      squareCorners = false;
      transparency = 1;
      useOverlayLayer = false;
      visible = true;
      widgetFollowInterfaceStyle = true;
      widgetOutlineColor = "primary";
      widgetOutlineEnabled = false;
      widgetOutlineOpacity = 1;
      widgetOutlineThickness = 1;
      widgetPadding = 8;
      widgetTransparency = 1;
    }
  ];
  barElevationEnabled = false;
  blurBorderEnabled = false;
  blurBorderSeeded = false;
  blurWallpaperOnOverview = true;
  builtInPluginSettings = {
    dms_clipboard_search = {
      trigger = "cb";
    };
    dms_power = {
      trigger = "pw";
    };
    dms_qr_generator = {
      trigger = "qrg";
    };
    dms_settings_search = {
      trigger = "?";
    };
  };
  clockFormat = "24h";
  configVersion = 42;
  cursorSettings = {
    dwl = {
      cursorHideTimeout = 0;
    };
    hyprland = {
      hideOnKeyPress = false;
      hideOnTouch = false;
      inactiveTimeout = 0;
    };
    niri = {
      hideAfterInactiveMs = 0;
      hideWhenTyping = false;
    };
    size = 24;
    theme = "Adwaita";
  };
  dashOptions = {
    weather = {
      widgets = [
        {
          city = true;
          col = 0;
          h = 2;
          id = "conditions";
          row = 0;
          tone = "primary";
          w = 2;
        }
        {
          col = 2;
          forecast = "chart";
          h = 2;
          id = "hourly";
          row = 0;
          w = 2;
        }
        {
          col = 0;
          h = 2;
          id = "sun";
          row = 2;
          tone = "";
          w = 1;
        }
        {
          col = 1;
          h = 2;
          id = "moon";
          row = 2;
          tone = "";
          w = 1;
        }
        {
          col = 2;
          graphics = true;
          h = 2;
          id = "humidity";
          row = 2;
          tone = "";
          w = 1;
        }
        {
          col = 3;
          graphics = true;
          h = 2;
          id = "wind";
          row = 2;
          tone = "";
          w = 1;
        }
      ];
    };
  };
  displayNameMode = "model";
  displayShowDisconnected = true;
  dmsWindowsFloatingSeeded = [ "niri" ];
  dockConfigs = [
    {
      autoHide = false;
      borderColor = "surfaceText";
      borderEnabled = false;
      borderOpacity = 1;
      borderThickness = 1;
      bottomGap = 0;
      editOnRightClick = false;
      enabled = true;
      followInterfaceStyle = true;
      groupByApp = false;
      iconSize = 40;
      id = "dock";
      indicatorStyle = "circle";
      isolateDisplays = true;
      itemSpacing = 4;
      launcherEnabled = false;
      launcherLogoBrightness = 0.5;
      launcherLogoColorOverride = "";
      launcherLogoContrast = 1;
      launcherLogoCustomPath = "";
      launcherLogoMode = "apps";
      launcherLogoSizeOffset = 0;
      magnification = false;
      magnificationExpand = false;
      magnificationProfile = "parabolic";
      magnificationScale = 130;
      margin = 0;
      maxVisibleApps = 0;
      maxVisibleRunningApps = 0;
      mode = "compact";
      name = "Dock";
      openOnOverview = true;
      order = [ ];
      position = 1;
      restoreSpecialWorkspaceOnClick = false;
      screenPreferences = [ "all" ];
      separatePinnedAndRunningApps = false;
      showOnFullscreen = false;
      showOnLastDisplay = true;
      showOverflowBadge = true;
      showTrash = false;
      smartAutoHide = true;
      spacing = 4;
      taskbarAlign = "center";
      transparency = 1;
      trashCustomCommand = "";
      trashFileManager = "default";
      useOverlayLayer = false;
      widgetExpansion = "popout";
      widgets = [
        {
          enabled = true;
          id = "dock_launcher";
          widgetId = "dockLauncher";
        }
        {
          enabled = true;
          id = "dock_apps";
          widgetId = "appsDock";
        }
        {
          enabled = true;
          id = "dock_trash";
          widgetId = "dockTrash";
        }
      ];
    }
  ];
  frameEnabled = true;
  frameMode = "separate";
  frameShowOnOverview = true;
  iconThemeDark = "Papirus-Light";
  iconThemeLight = "Papirus-Dark";
  iconThemePerMode = true;
  lockBeforeSuspend = true;
  loginctlLockIntegration = false;
  muxType = "zellij";
  osdPowerProfileEnabled = true;
  radiusStrength = 38;
  spotlightSectionViewModes = {
    apps = "list";
  };
  useAutoLocation = false;
  useSystemSoundTheme = true;
}
