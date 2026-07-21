{
  inputs,
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
let

  # https://yazi-rs.github.io/docs/tips/#helix-with-zellij
  yaziPicker = pkgs.writeShellScriptBin "yazi-picker" ''
    paths=$(${pkgs.yazi}/bin/yazi --chooser-file=/dev/stdout | while read -r; do printf "%q " "$REPLY"; done)

    if [[ -n "$paths" ]]; then
    	${pkgs.zellij}/bin/zellij action toggle-floating-panes
    	${pkgs.zellij}/bin/zellij action write 27 # send <Escape> key
    	${pkgs.zellij}/bin/zellij action write-chars ":open $paths"
    	${pkgs.zellij}/bin/zellij action write 13 # send <Enter> key
    	${pkgs.zellij}/bin/zellij action toggle-floating-panes
    fi

    ${pkgs.zellij}/bin/zellij action close-pane
  '';
in
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      nixd
      mpls
    ];

    # config.toml
    settings = {
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
      editor.soft-wrap = {
        enable = true;
      };
      keys = {
        normal = {
          C-y = lib.mkIf (config.programs.yazi.enable && config.programs.zellij.enable) [
            ":sh ${pkgs.zellij}/bin/zellij run -f -n yazi-picker -x 10%% -y 10%% --width 80%% --height 80%% -- ${yaziPicker}/bin/yazi-picker open %{buffer_name}"
          ];
        };
      };
    };

    # languages.toml
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          # formatter.command = lib.getExe pkgs.nixfmt; # Commented out, using the LSP formatter
        }
        {
          name = "markdown";
          auto-format = true;
          language-servers = [
            "mpls"
          ];
        }
      ];
      language-server = {
        nixd = {
          # Source: https://github.com/helix-editor/helix/issues/14003#issuecomment-3093186464
          command = lib.getExe pkgs.nixd;
          args = [ "--semantic-tokens=true" ];
          config.nixd =
            let
              myFlake = ''(builtins.getFlake "${osConfig.programs.nh.flake}")''; # Better than ''(builtins.getFlake "${inputs.self}")'' , so it doesn't depend on the nix store
              nixosOpts = "${myFlake}.nixosConfigurations.${osConfig.networking.hostName}.options";
            in
            {
              nixpkgs.expr = "import ${myFlake}.inputs.nixpkgs { }";
              formatting.command = [ "${lib.getExe pkgs.nixfmt}" ];
              options = {
                nixos.expr = nixosOpts;
                home-manager.expr = "${nixosOpts}.home-manager.users.type.getSubOptions []";
              };
            };
        };
        mpls = {
          command = lib.getExe pkgs.mpls;
          args = [
            "--no-auto"
            "--code-style"
            "--enable-footnotes"
            "--enable-emoji"
          ];
        };
      };

    };
  };
}
