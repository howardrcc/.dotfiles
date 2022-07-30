
{ config, pkgs, ... }:

{
 
  home-manager.users.howie = { pkgs, ... }: {
 
    home.packages = [ pkgs.git 
      pkgs.alacritty
      pkgs.git
      pkgs.openconnect
      pkgs.remmina
      pkgs.vlc
      pkgs.teams
      pkgs.discord
      pkgs.spotify
      #pkgs.spicetify-cli
     
#      pkgs.winePackages.stagingFull
      pkgs.wineWowPackages.stagingFull
      pkgs.winetricks
      pkgs.qbittorrent
      pkgs.filezilla
     # pkgs.lxqt.pavucontrol-qt
    ];

   
    programs.bash.enable = true;
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
      arcticicestudio.nord-visual-studio-code
     #vscodevim.vim
     #yzhang.markdown-all-in-one
      ];
    };

    programs.neovim = {
      enable = true;
      viAlias = true;
      #plugins = with pkgs.vimPlugins; [ vim-airline ];
      #settings = { ignorecase = true; };
      extraConfig = ''
        set mouse=a
        set tabstop=2
      '';
    };
  
  };


}
