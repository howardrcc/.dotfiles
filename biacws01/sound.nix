{ config, pkgs, ... }:

{

  boot.extraModprobeConfig = ''
     options snd_usb_audio vid=0x1235 pid=8012 device_setup=3
     options snd-hda-intel model=Realtek ALCS1200A,dell-headset-multi patch=hda-jack-retask.fw
   '';

  # Enable sound.
   sound.enable = false;
	 
# rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
#	media-session.enable = false;
#	wireplumber.enable= true;
};

   #environment.etc."asound.conf".text = ''defaults.pcm.!card "USB"   
   #                                       defaults.ctl.!card "USB"
   #                                     '';
   #sound.extraConfig =
   #''
   #  defaults.pcm.!card "USB"
   #  defaults.ctl.!card "USB"
   #'';

    #hardware.pulseaudio.support32Bit = true;  
    #hardware.pulseaudio.enable = true;
    #hardware.pulseaudio.package = pkgs.pulseaudioFull;
    
    #hardware.pulseaudio.extraConfig = ''
    #  load-module module-combine channels=2 channel_map=front-left,front-right
    #    '';
    # set-card-profile alsa_card.usb-Elite_Silicon_USB_Audio_Device-00 off
 
}
