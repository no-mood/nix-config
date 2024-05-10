{pkgs, ...}: {
  imports = [
    # ./pkg.nix
    ./git.nix
    ./nvim.nix
    ./zsh.nix
    ./bash.nix
    ./direnv.nix
    ./ssh.nix
    #./ranger.nix
    ./yazi.nix
  ];

  home.sessionVariables.EDITOR = "nvim";

  home.packages = with pkgs; [
    # pkg or unstable.pkg

    # Must have
    wget
    curl
    neofetch
    htop

    # Fun
    cmatrix
    cbonsai
    cowsay

    # File manager
    mc
    lf
    ranger

    # lunarvim (TMP)
    unstable.lunarvim
  ];

  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      window-title-basename = true;
    };
  };

  programs.ncspot = {
    enable = true;
    package = pkgs.ncspot.override {
      withCover = true;
      withMPRIS = true;
    };
    settings = {
    };
  };
}
