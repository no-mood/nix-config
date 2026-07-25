{ pkgs, ... }:
let
  wolInterface = "enp4s0"; # wakeonlan 88:d7:f6:7f:83:c6
  # AMD RX 9060 XT ROCm devices passed to llama-cpp container
  gpuDevices = [
    "/dev/kfd"
    "/dev/dri/renderD128"
  ];
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
    ../common/users/family

    ../common/optional/limine.nix
    ./graphics.nix
    ../common/optional/drivers.nix

    ../common/optional/gnome-DE.nix
    ../common/optional/niri.nix
    ../common/optional/kdeconnect.nix

    ../common/optional/printing.nix
    ../common/optional/virtualisation.nix
    ../common/optional/ratbagd.nix
    ../common/optional/gaming.nix
    ../common/optional/wireshark.nix
    ../common/optional/catppuccin.nix
    ../common/optional/bcc.nix
    ../common/optional/tailscale-client.nix
    ../common/optional/restic-client.nix
    ../common/optional/zerotier-client.nix

    # Servers
    ../common/optional/caddy.nix
    ../common/optional/iperf-server.nix
    ../common/optional/restic-server.nix
    ../common/optional/sunshine-server.nix
    (import ../common/optional/llama-cpp-container.nix {
      inherit gpuDevices;
    })

  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.systemd.enable = true;
  };

  networking.hostName = "dra"; # Was "fehu".

  environment.systemPackages = with pkgs; [
  ];

  networking.interfaces.${wolInterface}.wakeOnLan = {
    enable = true;
    policy = [
      "magic"
    ];
  };

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05";
}
