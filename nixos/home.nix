{ pkgs, inputs, ... }:

{

  imports = [
    inputs.dms.homeModules.dank-material-shell
  ];

  home.stateVersion = "25.11";
  
  programs.dank-material-shell = {
    enable = true;
      enableSystemMonitoring = true;
      dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
  
  programs.git = {
    enable = true;
    settings = {
      user.email = "howardchingchung@protonmail.com";
      user.name = "Howard Ching Chung";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.zsh = {
    enable = true;
  
  # Install plugins via Nix
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;  # if you want this too
  
    # oh-my-zsh config
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell"; 
      plugins = [ "git" "docker" ];  # only built-in plugins here
    # remove zsh-autosuggestions and zsh-autocomplete from this list
    };
    shellAliases = {
      ll = "ls -al";
      update = "sudo nixos-rebuild switch --flake ~/nixos";
    };
  };

# direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;  # better nix integration
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      # LSPs
      lua-language-server
      nil # nix LSP
      nodePackages.typescript-language-server
    
      # Tools LazyVim expects
      gcc
      gnumake
      nodejs
      ripgrep
      fd
      lazygit
    
      # For treesitter compilation
      tree-sitter
    ];
    plugins = [
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      pkgs.vimPlugins.markdown-preview-nvim
    ];

  };

  home.packages = with pkgs; [
    #claude-code
    inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
    gcc  # treesitter needs a compiler
  #  ffmpegthumbs    # video thumbnails
    kdePackages.kdegraphics-thumbnailers
    remmina
    lutris
    protonup-qt
    wine
    winetricks
  #  git
  #ripgrep
  #fd
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {

      #monitor = ",5120x1440@120,0x0,1";
      # in je Hyprland-config (Home Manager of hyprland.conf):
      monitor = [
       "DP-3, 5120x1440@120, 0x0, 1"   # je echte ultrawide, primair
        "DP-1, disable"                  # geforceerde virtuele connector: uit voor Hyprland
      ];

      exec-once = [
        "dms run"  # or: systemctl --user start dms
        "steam -silent -pipewire"  # start Steam minimized to tray for Remote Play host (EGL/GBM fix is in configuration.nix)
      ];


      "$mainMod" = "SUPER";

      bind = [
        "$mainMod, Return, exec, ghostty"
        "$mainMod, Q, killactive"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 1;
      };

      decoration = {
        rounding = 10;
      };
      
      #settings in source do not require nixos-rebuild and are applied immediate>
      source = [
        "./extra.conf"
      ];
    };
    
    extraConfig = ''
        $mainMod = SUPER

      # Switch workspaces with mainMod + [0-9]
        bind = $mainMod, 1, workspace, 1
        bind = $mainMod, 2, workspace, 2
        bind = $mainMod, 3, workspace, 3
        bind = $mainMod, 4, workspace, 4
        bind = $mainMod, 5, workspace, 5
        bind = $mainMod, 6, workspace, 6
        bind = $mainMod, 7, workspace, 7
        bind = $mainMod, 8, workspace, 8
        bind = $mainMod, 9, workspace, 9
        bind = $mainMod, 0, workspace, 10

      # Move active window and follow to workspace
        bind = $mainMod CTRL, 1, movetoworkspace, 1
        bind = $mainMod CTRL, 2, movetoworkspace, 2
        bind = $mainMod CTRL, 3, movetoworkspace, 3
        bind = $mainMod CTRL, 4, movetoworkspace, 4
        bind = $mainMod CTRL, 5, movetoworkspace, 5
        bind = $mainMod CTRL, 6, movetoworkspace, 6
        bind = $mainMod CTRL, 7, movetoworkspace, 7
        bind = $mainMod CTRL, 8, movetoworkspace, 8
        bind = $mainMod CTRL, 9, movetoworkspace, 9
        bind = $mainMod CTRL, 0, movetoworkspace, 10
        bind = $mainMod CTRL, bracketleft, movetoworkspace, -1
        bind = $mainMod CTRL, bracketright, movetoworkspace, +1

    # Move active window to a workspace with mainMod + SHIFT + [0-9]
        bind = $mainMod SHIFT, 1, movetoworkspacesilent, 1
        bind = $mainMod SHIFT, 2, movetoworkspacesilent, 2
        bind = $mainMod SHIFT, 3, movetoworkspacesilent, 3
        bind = $mainMod SHIFT, 4, movetoworkspacesilent, 4
        bind = $mainMod SHIFT, 5, movetoworkspacesilent, 5
        bind = $mainMod SHIFT, 6, movetoworkspacesilent, 6
        bind = $mainMod SHIFT, 7, movetoworkspacesilent, 7
        bind = $mainMod SHIFT, 8, movetoworkspacesilent, 8
        bind = $mainMod SHIFT, 9, movetoworkspacesilent, 9
        bind = $mainMod SHIFT, 0, movetoworkspacesilent, 10
        bind = $mainMod SHIFT, bracketleft, movetoworkspacesilent, -1
        bind = $mainMod SHIFT, bracketright, movetoworkspacesilent, +1

        # Move (vim style)
        bind = $mainMod CTRL, H, movewindow, l
        bind = $mainMod CTRL, L, movewindow, r
        bind = $mainMod CTRL, K, movewindow, u
        bind = $mainMod CTRL, J, movewindow, d

        bind = $mainMod CTRL, left, movewindow, l
        bind = $mainMod CTRL, right, movewindow, r
        bind = $mainMod CTRL, up, movewindow, u
        bind = $mainMod CTRL, down, movewindow, d


        # Move focus with mainMod + arrow keys
 
        bind = $mainMod, H, movefocus, l
        bind = $mainMod, L, movefocus, r
        bind = $mainMod, K, movefocus, u
        bind = $mainMod, J, movefocus, d

        bind = $mainMod, left, movefocus, l
        bind = $mainMod, right, movefocus, r
        bind = $mainMod, up, movefocus, u
        bind = $mainMod, down, movefocus, d

       # Application Launchers
        bind = $mainMod, space, exec, dms ipc call spotlight toggle
        bind = $mainMod, V, exec, dms ipc call clipboard toggle
        bind = $mainMod, M, exec, dms ipc call processlist focusOrToggle
        bind = $mainMod, comma, exec, dms ipc call settings focusOrToggle
        bind = $mainMod, N, exec, dms ipc call notifications toggle
        bind = $mainMod, Y, exec, dms ipc call dankdash wallpaper
        bind = $mainMod, TAB, exec, dms ipc call hypr toggleOverview

        # Security
        bind = $mainMod ALT, L, exec, dms ipc call lock lock

        # Audio Controls
        bindel = , XF86AudioRaiseVolume, exec, dms ipc call audio increment 3
        bindel = , XF86AudioLowerVolume, exec, dms ipc call audio decrement 3
        bindl = , XF86AudioMute, exec, dms ipc call audio mute

        # Brightness Controls
     #   bindel = , XF86MonBrightnessUp, exec, dms ipc call brightness increment 5
     #   bindel = , XF86MonBrightnessDown, exec, dms ipc call brightness decrement 5

        animations {
         enabled = true # Set to false to disable all animations
         animation = workspaces, 0, 1, default
        }

      '';
  };
}
