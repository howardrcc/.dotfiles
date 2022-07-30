{ config, pkgs, ... }:

{

#  boot.extraModprobeConfig = ''
#    options snd_usb_audio vid=0x1235 pid=8012 device_setup=3
#  '';

  # Enable sound.
   sound.enable = true;
   #environment.etc."asound.conf".text = ''defaults.pcm.!card "USB"   
   #                                       defaults.ctl.!card "USB"
   #                                     '';
    sound.extraConfig =
    ''
      defaults.pcm.!card "USB"
      defaults.ctl.!card "USB"
    '';
    #hardware.pulseaudio.support32Bit = true;  
    hardware.pulseaudio.enable = true;
    #hardware.pulseaudio.package = pkgs.pulseaudioFull;
    security.rtkit.enable = true;
    #services.pipewire = {
    #  enable = true;
    #  alsa.enable = true;
    #  alsa.support32Bit = true;
    #  pulse.enable = true;
    #  jack.enable = true;
    #};
    hardware.pulseaudio.extraConfig = ''
      load-module module-combine channels=2 channel_map=front-left,front-right
        '';
    # set-card-profile alsa_card.usb-Elite_Silicon_USB_Audio_Device-00 off
 
#services.jack = {
#    jackd.enable = true;
#    # support ALSA only programs via ALSA JACK PCM plugin
#    alsa.enable = false;
#    # support ALSA only programs via loopback device (supports programs like Steam)
#    loopback = {
#      enable = true;
#      # buffering parameters for dmix device to work with ALSA only semi-professional sound programs
#      #dmixConfig = ''
#      #  period_size 2048
#      #'';
#    };
#  };
}