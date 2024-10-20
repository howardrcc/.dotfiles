{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./grafana.nix
#      ./homer.nix
	    ./nginx.nix
	    ./nextcloud.nix
	    ./vscode.nix
	    ./docker.nix #pihole
	    ./teku.nix
      ./syncthing.nix
      ./unifi.nix
      <home-manager/nixos>
#     ./samba.nix
#     ./plex.nix
    ];

  nixpkgs.overlays = [
    (import /home/howie/.dotfiles/home/overlays.nix)

  ];

  services.tailscale.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub.gfxmodeEfi = "1920x1080";

  # Enable networking
  networking = {
 #   networkmanager.enable = true;
  #  networkmanager.insertNameservers = ["1.1.1.1"];
    nameservers = [ "1.1.1.1" "8.8.8.8"];
    hostName = "home"; # Define your hostname.
  #  defaultGateway =  {
  #     address = "192.168.1.1";
  #     interface = "enp5s0";
  #     };
  
  #  interfaces.enp5s0.ipv4.addresses = [{
  #      address = "192.168.1.132";
  #      prefixLength = 24;
  #   }];
    
    firewall.allowedTCPPorts = [ 3389 ];
    firewall.enable = false;
  
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
};
  
# Enable the OpenSSH daemon.
  services.openssh = {
  	enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
    ports = [ 69 ];
 };
 

  programs.ssh.knownHosts = {
  	"github.com" = {
		hostNames = [ "github.com"];
		publicKeyFile = "/home/howie/.pubkey/ed25519.pub";
	};
  };


  services.jellyfin.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
  };
  
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";
  
# Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "euro";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.howie = {
    isNormalUser = true;
    description = "howie";
    extraGroups = [ "networkmanager" "wheel" "syncthing" "docker"];
    openssh.authorizedKeys.keyFiles = [ 
      "/home/howie/.pubkey/ed25519.pub"
			"/home/howie/.pubkey/cb.pub"
      "/home/howie/.pubkey/bia.pub"
				      ];

  };

  users.users.jellyfin = {
        extraGroups = [ "syncthing" "users"];
  };
 

#  users.users.plex = {        extraGroups = [ "syncthing" "users"];  };

  users.users.syncthing = {
        extraGroups = [ "syncthing" "users"];
  };
  
  home-manager.users.howie = { pkgs, ... }: {
    home.packages = [ pkgs.git
                    pkgs.alacritty
                    ];
#    home.stateVersion = "22.05";

    programs.bash.enable = true;
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
        extraConfig = ''
            "custom conf!
            syntax on
            colorscheme delek
            set tabstop=4
		    set shiftwidth=4
            set expandtab   
        	'';
	     };
	};

 

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #neovim #vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox
    kate
    tmux
    gparted
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
    programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
   };
    environment.variables.EDITOR = "nvim";
 

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leavecatenate(variables, "bootdev", bootdev)
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
