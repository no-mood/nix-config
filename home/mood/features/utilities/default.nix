{ pkgs, ... }: {
  imports = [
     # ./pkg.nix
  ];

  home.packages = with pkgs; [ 
    # pkg or unstable.pkg
    
    telegram-desktop
    unstable.spotify
   ];
}
