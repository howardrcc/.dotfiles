# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
       <home-manager/nixos>
      ./home-manager.nix
		  ./docker.nix
      ./sound.nix
      
    ];

  nixpkgs.config.allowUnfree = true;
  home-manager.useGlobalPkgs = true;
	security.sudo.wheelNeedsPassword = false;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" "ntfs"];
  boot.zfs.devNodes = "/dev/";
  #boot.kernelPatches = [{
  #  name = "snd-usb-audio_low-latency";
  #  patch = ./patches/linux5.11-snd-usb-audio.patch;
  #}];
  ##  options snd-usb-audio max_packs=1 max_packs_hs=1 max_urbs=12 sync_urbs=4 max_queue=18

  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.pools = [ "rpool" ];

  networking.hostName = "biacws01"; # Define your hostname.
  networking.hostId = "1ddc23f2"; 
    
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";
 
#   Select internationalisation properties.
   i18n.defaultLocale = "en_US.UTF-8";
 # i18n.extraLocaleSettings = {
 #   LC_ADDRESS = "en_US.UTF-8";
 #   LC_IDENTIFICATION = "en_US.UTF-8";
 #   LC_MEASUREMENT = "en_US.UTF-8";
 #   LC_MONETARY = "en_US.UTF-8";
 #   LC_NAME = "en_US.UTF-8";
 #   LC_NUMERIC = "en_US.UTF-8";
 #   LC_PAPER = "en_US.UTF-8";
 #   LC_TELEPHONE = "en_US.UTF-8";
 #   LC_TIME = "en_US.UTF-8";
 # };
  
   console = {
     font = "Lat2-Terminus16";
     keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
   };

#hardware.opengl.driSupport32Bit = true;
  
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "euro";
    videoDrivers = [ "nvidia"];
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };

  # Enable the Plasma 5 Desktop Environment.
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";  
	
  # Enable CUPS to print documents.
  # services.printing.enable = true;
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.howie = {
		description = "howardchingchung@gmail.com";
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "audio" "jackaudio"]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keyFiles = [ 
      "/home/howie/.ssh/id_ed25519.pub"
		];
	  packages = with pkgs; [
       firefox
       #thunderbird
	#		 git
     ];
   };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
 
    environment.systemPackages = with pkgs; [
     #neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      # libjack2 jack2 qjackctl
      #  pavucontrol libjack2 jack2 qjackctl jack2Full jack_capture 
      #   wine-staging winetricks
      #libsForQt5.qtstyleplugin-kvantum
   ];

      

     environment.variables = {
        # This will become a global environment variable
       "QT_STYLE_OVERRIDE"="kvantum";
     };
 
  # Some programs need SUID wrappers, can be configured further or are started in user sessions.
  
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  
  services.openssh = {
    enable = true;
	  permitRootLogin = "no";
    ports = [ 69 ];
	  #passwordAuthentication = false;
  };
  
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.enable = false;


  hardware = {
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        #vaapiIntel #needed for nvidia?
        vaapiVdpau
        libvdpau-va-gl
      ];
      driSupport32Bit = true;
      # FIX required to expose LD_LIBRARY_PATH
      setLdLibraryPath = true; 
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

