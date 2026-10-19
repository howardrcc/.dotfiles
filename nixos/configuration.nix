# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # Focusrite Scarlett interfaces power up with their hardware Monitor/Headphone
  # outputs muted (and the R channel unrouted) until something unmutes them via
  # ALSA mixer controls - normally done by Focusrite Control on Windows/Mac. Any
  # physical unplug/replug (or reboot) resets these registers to that default,
  # so this reapplies our desired state every time the card is (re)detected.
  # Using numid (not control names) throughout: the simple-mixer names for the
  # boolean switches don't actually resolve via `amixer sset` on this device
  # ('Master 1 (Monitor) Playback Switch' -> "Unable to find simple control"),
  # only `cset numid=N` reliably works. Numids are stable for this exact
  # card/driver/kernel combo (verified via `amixer -c 2 contents`).
  #
  # Desired routing: Monitor out (1/2, the big front-panel knob) carries
  # PCM 1/2 (i.e. whatever the default PipeWire sink plays); Headphone/Line
  # 3-4 output is intentionally left muted (it's the same DAC pair either way).
  scarlettUnmuteScript = pkgs.writeShellScript "scarlett-unmute" ''
    card=$(echo "$1" | sed 's/^controlC//')
    usbid=$(cat /proc/asound/card$card/usbid 2>/dev/null)
    if [ "$usbid" = "1235:8012" ]; then
      amixer="${pkgs.alsa-utils}/bin/amixer -c $card"
      $amixer cset numid=10 on,on  >/dev/null 2>&1  # Master 1 (Monitor) Playback Switch: on
      $amixer cset numid=12 1      >/dev/null 2>&1  # Master 1L (Monitor) Source: PCM 1
      $amixer cset numid=13 2      >/dev/null 2>&1  # Master 1R (Monitor) Source: PCM 2
      $amixer cset numid=14 off,off >/dev/null 2>&1 # Master 2 (Headphone/Line 3-4): off
    fi
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nvme.nix
#      ./games.nix
#      ./pw.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

# 1. Lever de EDID-blob aan onder lib/firmware/edid/
  hardware.firmware = [
    (pkgs.runCommand "custom-edid" {} ''
      mkdir -p $out/lib/firmware/edid
      cp ${./1920x1080.bin} $out/lib/firmware/edid/1920x1080.bin
    '')
  ];

# Zet firmware-compressie uit (simpelst, geldt systeembreed)
hardware.firmwareCompression = "none";
  boot.kernelParams = [
    "nvidia_drm.modeset=1"
    "video=DP-1:e"                         # connector forceren (dit deel werkt wél op NVIDIA)
    "drm.edid_firmware=DP-1:edid/1920x1080.bin"  # ingebouwde kernel-EDID, geen bestand nodig
  ];


# 2. Zorg dat de firmware ook in de initrd zit (NVIDIA vraagt 'm vroeg op)
  hardware.enableRedistributableFirmware = true;
  nix.settings.trusted-users = [ "howie" ];
  
  networking = {
      hostName = "nixos"; # Define your hostname.
      networkmanager.enable = true;
      firewall.enable = false;
 
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  };
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # 32-bit support for wine/games
  hardware.graphics.enable32Bit = true;  # was hardware.opengl.enable32Bit before 24.11

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
  # You can disable this if you're only using the Wayland session.
#  services.xserver.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        FastConnectable = true;
      };
      Policy = {
      # Enable all controllers when they are found. This includes
      # adapters present on start as well as adapters that are plugged
      # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };
  
  services.blueman.enable = true;


  # Enable the KDE Plasma Desktop Environment.
  services = {
    displayManager = {
      defaultSession = "hyprland";
      autoLogin = {
        enable = true;
        user = "howie";
      };
      sddm = {
        enable = true;
        wayland.enable = true;
        theme= "sddm-astronaut-theme";
        extraPackages = with pkgs; [
          qt6.qt5compat
          qt6.qtsvg
          qt6.qtmultimedia
        ];
      };
    };
  };

 #using hyprland 

# Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "euro";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

# Tailscale vpn
  services.tailscale.enable = true;
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Auto-unmute the Focusrite Scarlett's hardware outputs on every plug-in/boot.
  # See scarlettUnmuteScript above for why this is needed.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="sound", KERNEL=="controlC*", RUN+="${scarlettUnmuteScript} %k"
  '';

# Example for /etc/nixos/configuration.nix
  services.syncthing = {
    enable = true;
    openDefaultPorts = true; # Open ports in the firewall for Syncthing. (NOTE: this will not open syncthing gui port)
  };
  # firewall is disabled:
  #  networking.firewall.allowedTCPPorts = [ 8384 ];
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.howie = {
    isNormalUser = true;
    description = "howie";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFmHcW93xY45VuYEPP9QzVt1UxgDx8PkdCW1M8KfJaRX"
    ];
  
    extraGroups = [ "docker" "networkmanager" "wheel" "syncthing" ];
    packages = with pkgs; [
      kdePackages.kate
      proton-pass
    #  thunderbird
    ];
  };
  
#    history.size = 9999;

  # Install firefox.
  programs = {
    firefox.enable = true;
    hyprland.enable = true;
    zsh.enable = true;
    ssh.startAgent = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      gamescopeSession.enable = true;  # optional
      extraPackages = with pkgs; [ pipewire ];
    };
  };


# Example for /etc/nixos/configuration.nix
# In configuration.nix
programs.thunar = {
  enable = true;
  plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
};

# Also useful for thumbnails and trash support
services.gvfs.enable = true;
services.tumbler.enable = true;

  # Game streaming host (use with the Moonlight client).
  # capSysAdmin is required for KMS/DRM frame capture on Wayland (no portal
  # picker popup, unlike Steam Remote Play). NVENC is used automatically on NVIDIA.
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
# Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Tell EGL where to find NVIDIA's external-platform configs (e.g. the GBM
  # backend, 15_nvidia_gbm.json). Without this, apps that init EGL on the DRM
  # render node fail with EGL_NOT_INITIALIZED (0x3001) — notably Steam's
  # Wayland desktop capture, which then misleadingly says "run with -pipewire".
  environment.sessionVariables.__EGL_EXTERNAL_PLATFORM_CONFIG_DIRS =
    "/run/opengl-driver/share/egl/egl_external_platform.d:/run/opengl-driver-32/share/egl/egl_external_platform.d";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alsa-utils
    fd
    fzf
    ghostty
    grim
    nodejs
    python3
    ripgrep
    wget
    oh-my-zsh #check starship
    zsh
    jdk21_headless
  # lutris
#    protonup-qt
    spotify
    tmux
    unzip
    statix #nixos linter
    qbittorrent
    vlc
    
  #    libdrm
  # or sddm-chili-theme, sddm-astronaut-theme, etc.
    sddm-astronaut
    qt6.qtsvg # some themes need this for rendering
    qt6.qt5compat
    qt6.qtmultimedia
    where-is-my-sddm-theme
  # installed with flakes
	#    git
  #  vim/nvim
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
