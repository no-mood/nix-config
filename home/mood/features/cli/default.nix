{ pkgs, ... }: {
  imports = [
    # ./pkg.nix
    ./git.nix
  ];

  home.packages = with pkgs; [ 
    # pkg or unstable.pkg
    
    # Must have
    neofetch
    
    # Fun
    lf
    cmatrix
    cbonsai
    
    # File manager
    mc
    lf
    
   ];
}
