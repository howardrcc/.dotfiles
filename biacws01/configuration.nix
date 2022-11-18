{ config, pkgs, lib, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix		
      ./home-manager.nix
		  ./docker.nix
      ./sound.nix
      ./systemtools.nix
#			./unifi.nix
      ./vscode.nix
      ./vfio.nix
      ./vfio-extra.nix
			./programs.nix
      ./grafana.nix
       <home-manager/nixos>     
    ];
  
	time.hardwareClockInLocalTime = true;
	users.users.howie = {
		description = "howardchingchung@gmail.com";
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "audio" "jackaudio" "syncthing" "libvirtd"]; 
    openssh.authorizedKeys.keyFiles = [ 
      "/home/howie/.ssh/id_ed25519.pub"
		];
	  packages = with pkgs; [
       firefox
			 alsa-tools #gui
			 pavucontrol
       psmisc
     ];
   };

  environment.systemPackages = with pkgs; [
    #neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    glibcLocales
    #libsForQt5.qt5.qttools
    libsForQt5.ark
    lsof
    usbutils

   ];
  #general settings
  security.sudo.wheelNeedsPassword = false;
  nixpkgs.config.allowUnfree = true;
#	programs.ssh.startAgent = true;
  home-manager.useGlobalPkgs = true;
	

  #boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" "ntfs"];
  boot.zfs.devNodes = "/dev/";
  services.zfs.trim.enable = true;
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.pools = [ "rpool" ];

  #networking
  networking.hostName = "biacws01"; # Define your hostname.
  networking.hostId = "1ddc23f2"; 
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.firewall.enable = false;
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

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


  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "nl_NL.utf-8";
  i18n.supportedLocales = ["all"];
  i18n.glibcLocales = pkgs.glibcLocales;
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
   };

  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "euro";
    videoDrivers = [ "nvidia"];
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };

  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";  
  services.printing.enable = true;
  
  services.openssh = {
    enable = true;
	  permitRootLogin = "no";
    ports = [ 69 ];
	  #passwordAuthentication = false;
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

