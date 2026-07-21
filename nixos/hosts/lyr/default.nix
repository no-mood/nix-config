{ pkgs, ... }:
let
  wolInterface = "enp1s0"; # wakeonlan e8:ff:1e:d7:3a:72
  # Intel N100 iGPU render node — used for VA-API / ML acceleration (Immich, Jellyfin).
  # Jellyfin additionally needs the DRM node: [ "/dev/dri/card0" ] ++ accelerationDevices
  accelerationDevices = [ "/dev/dri/renderD128" ];
in
{
  imports = [
    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # Import disko config
    ./disk-config.nix

    # Template-based. Add all users on this host
    ../common/global
    ../common/users/mood

    ../common/optional/systemd-boot.nix
    ./graphics.nix
    ../common/optional/docker.nix
    ../common/optional/tailscale-client.nix
    ../common/optional/restic-client.nix

    (import ../common/optional/immich-container.nix { inherit accelerationDevices; })
    # (import ../common/optional/jellyfin-container.nix {
    #   accelerationDevices = [ "/dev/dri/card0" ] ++ accelerationDevices;
    # })
    # ../common/optional/calibre-container.nix  # FIXME: pip-chill broken on python 3.14
    # ../common/optional/miniflux-container.nix
    # ../common/optional/minecraft-container.nix
    # ../common/optional/factorio-container.nix
    # ../common/optional/nixarr-server.nix
    # ../common/optional/ollama-server.nix
    # ../common/optional/restic-server.nix

    ../common/optional/caddy.nix
    #../common/optional/postgresql-server.nix  # postgres now internal to each container
    ../common/optional/iperf-server.nix
    ../common/optional/opencode-server.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.hostName = "lyr"; # Define your hostname.

  environment.systemPackages = with pkgs; [
  ];

  networking.interfaces.${wolInterface}.wakeOnLan = {
    enable = true;
    policy = [ "magic" ];
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.05";
}
