{
  gpuDevices ? [ ],
  ...
}:
{
  pkgs,
  config,
  ...
}:
let
  port = 8080;
  hostname = config.networking.hostName;
  hostHardwareGraphics = config.hardware.graphics;
  hostNixpkgsConfig = config.nixpkgs.config;
in
{
  containers.llama-cpp = {
    autoStart = true;
    allowedDevices = map (dev: {
      node = dev;
      modifier = "rw";
    }) gpuDevices;
    bindMounts = builtins.listToAttrs (
      map (dev: {
        name = dev;
        value = {
          hostPath = dev;
          isReadOnly = false;
        };
      }) gpuDevices
    );
    config =
      { config, ... }:
      let
        llamaCppPackage =
          if config.nixpkgs.config.rocmSupport then
            pkgs.llama-cpp-rocm
          else if config.nixpkgs.config.cudaSupport then
            pkgs.llama-cpp.override { cudaSupport = true; }
          else
            pkgs.llama-cpp;
      in
      {
        hardware.graphics = hostHardwareGraphics;
        nixpkgs.config = hostNixpkgsConfig;

        # Required for GPU access (renderD128) inside the container
        users.groups.render = { };
        systemd.services.llama-cpp.serviceConfig.SupplementaryGroups = [ "render" ];

        services.llama-cpp = {
          enable = true;
          inherit port;
          package = llamaCppPackage;
          openFirewall = true;
          # MoE models with expert offloading via --n-cpu-moe 15
          settings.models-preset = pkgs.writeText "models.ini" ''
            [hf:Qwen3.6-35B-A3B]
            hf-repo = unsloth/Qwen3.6-35B-A3B-GGUF
            hf-file = Qwen3.6-35B-A3B-Q4_K_M.gguf
            alias = qwen3.6
            temp = 0.7

            [hf:Devstral-2-22B]
            hf-repo = bartowski/Devstral-2-22B-GGUF
            hf-file = Devstral-2-22B-Q4_K_M.gguf
            alias = devstral
            temp = 0.7

            [hf:Qwen2.5-Coder-14B]
            hf-repo = bartowski/Qwen2.5-Coder-14B-Instruct-GGUF
            hf-file = Qwen2.5-Coder-14B-Instruct-Q6_K.gguf
            alias = qwen-coder
            temp = 0.7
            top-p = 0.95
            top-k = 40

            [hf:Gemma-4-E4B]
            hf-repo = unsloth/gemma-4-E4B-it-GGUF
            hf-file = gemma-4-E4B-it-Q6_K.gguf
            alias = gemma4-small
            temp = 0.7
          '';
        };

        system.stateVersion = "26.05";
      };
  };

  services.caddy.virtualHosts."llama-cpp.${hostname}.${config.sensitive.myDomain}".extraConfig = ''
    reverse_proxy 127.0.0.1:${toString port}
  '';
}
