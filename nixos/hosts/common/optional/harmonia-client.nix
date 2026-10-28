{ config, ... }:
{
  nix.settings = {
    extra-substituters = [ "https://harmonia.${config.sensitive.myDomain}" ];
    extra-trusted-public-keys = [
      "cache.mesh-1:/Aj23vo28csoqBXboS+A5JGcxqHXvm7k/NbKxrYes9E="
    ];
    fallback = true;
  };
}
