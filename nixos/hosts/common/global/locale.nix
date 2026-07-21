{
  ...
}:
{
  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocales = [ "it_IT.UTF-8/UTF-8" ]; # Optionally (BEWARE: requires a different format with the added /UTF-8)

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Configure keymap in xserver
  services.xserver.xkb = {
    layout = "it";
    variant = "us";
    # This is known as "Italian with US layout" and allows you to type Italian accents with ALT-GR + vowel keys, while keeping the US layout for other keys.
  };

  # Configure console keymap
  console.useXkbConfig = true;
}
