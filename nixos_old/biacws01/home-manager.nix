
{ config, pkgs, ... }:

{
 
  home-manager.users.howie = { pkgs, ... }: {
 
    home.packages = [ pkgs.git 
      pkgs.alacritty
#		pkgs.discord
      pkgs.git
      pkgs.filezilla
			pkgs.libreoffice-qt
#      pkgs.openconnect_unstable
      pkgs.remmina
      pkgs.teams
      pkgs.spotify
      pkgs.p7zip
      pkgs.gparted      
      pkgs.celluloid
      pkgs.minecraft
      pkgs.mpv
      pkgs.qbittorrent
      pkgs.vlc
      pkgs.tmux
     # pkgs.wineWowPackages.stagingFull
     # pkgs.winetricks

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

      
    programs.fish.enable = true;
    programs.fish.shellInit = "set -U fish_prompt_pwd_dir_length 0";
  
		
  }; #end home-manager

  users.users.howie.shell = pkgs.fish;

}
