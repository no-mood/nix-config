{
  confi,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  programs.neovim = {
    enable = false; # using nixvim
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true; # Alias vimdiff to nvim -d.

    extraConfig = ''

    '';
  };

  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    colorschemes.catppuccin.enable = true;

    plugins = {
      lightline.enable = true;
      dashboard.enable = true;
      neo-tree.enable = true;
      nix.enable = true;
      telescope.enable = true;
      telescope.extensions.fzf-native.enable = true;
      nvim-tree.enable = true;
      #direnv.enable = true;
      copilot-vim.enable = true;
    };
    extraPlugins = with pkgs.vimPlugins; [
      #vim-nix
      zoxide-vim
      #telescope-zoxide
      #nvchad
      #nvchad-ui
    ];
  };
}
