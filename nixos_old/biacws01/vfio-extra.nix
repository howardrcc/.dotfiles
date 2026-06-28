{ config, pkgs, ... }:
{
   # Add binaries to path so that hooks can use it
  systemd.services.libvirtd = {
    path = let
             env = pkgs.buildEnv {
               name = "qemu-hook-env";
               paths = with pkgs; [
                 bash
                 libvirt
                 kmod
                 systemd
                 ripgrep
                 sd
               ];
             };
           in
             [ env ];
  };
  # Link hooks to the correct directory
  system.activationScripts.libvirt-hooks.text =
  ''
    ln -Tfs /etc/libvirt/hooks /var/lib/libvirt/hooks
  '';


  environment.etc = {
    "libvirt/hooks/qemu" = {
      text =
      ''
        #!/run/current-system/sw/bin/bash
        #
        # Author: Sebastiaan Meijer (sebastiaan@passthroughpo.st)
        #
        # Copy this file to /etc/libvirt/hooks, make sure it's called "qemu".
        # After this file is installed, restart libvirt.
        # From now on, you can easily add per-guest qemu hooks.
        # Add your hooks in /etc/libvirt/hooks/qemu.d/vm_name/hook_name/state_name.
        # For a list of available hooks, please refer to https://www.libvirt.org/hooks.html
        #

        GUEST_NAME="$1"
        HOOK_NAME="$2"
        STATE_NAME="$3"
        MISC="''${@:4}"

        BASEDIR="$(dirname $0)"

        HOOKPATH="$BASEDIR/qemu.d/$GUEST_NAME/$HOOK_NAME/$STATE_NAME"

        set -e # If a script exits with an error, we should as well.

        # check if it's a non-empty executable file
        if [ -f "$HOOKPATH" ] && [ -s "$HOOKPATH"] && [ -x "$HOOKPATH" ]; then
            eval \"$HOOKPATH\" "$@"
        elif [ -d "$HOOKPATH" ]; then
            while read file; do
                # check for null string
                if [ ! -z "$file" ]; then
                  eval \"$file\" "$@"
                fi
            done <<< "$(find -L "$HOOKPATH" -maxdepth 1 -type f -executable -print;)"
        fi
      '';
      mode = "0755";
    };

    "libvirt/hooks/kvm.conf" = {
      text =
      ''
        VIRSH_GPU_VIDEO=pci_0000_08_00_0
        VIRSH_GPU_AUDIO=pci_0000_08_00_1
        VIRSH_GPU_USB=pci_0000_08_00_2
        VIRSH_GPU_SB=pci_0000_08_00_3
      '';
      mode = "0755";
    };

    "libvirt/hooks/qemu.d/win10/prepare/begin/start.sh" = {
      text =
      ''
        #!/run/current-system/sw/bin/bash

        # Debugging
        exec 19>/home/howie/Desktop/startlogfile
        BASH_XTRACEFD=19
        set -x

        # Load variables we defined
        source "/etc/libvirt/hooks/kvm.conf"

        # Change to performance governor
        echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

        # Stop display manager
        systemctl stop display-manager.service
 
        # Unbind VTconsoles
        echo 0 > /sys/class/vtconsole/vtcon0/bind
        echo 0 > /sys/class/vtconsole/vtcon1/bind

        # Unbind EFI Framebuffer
        echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

        # Avoid race condition
        sleep 2

        #unbind (zelfde effect als detach?), some devices persist after modprobe -r
        modprobe vfio-pci --first-time
        
            echo "0000:08:00.0" > /sys/bus/pci/devices/0000\:08\:00.0/driver/unbind
          sleep 1
            echo "0000:08:00.1" > /sys/bus/pci/devices/0000\:08\:00.1/driver/unbind
          sleep 1
            echo "0000:08:00.2" > /sys/bus/pci/devices/0000\:08\:00.2/driver/unbind
          sleep 1
            echo "0000:08:00.3" > /sys/bus/pci/devices/0000\:08\:00.3/driver/unbind
          sleep 1

        

        # Unload NVIDIA kernel modules
        modprobe -r nvidia_modeset --first-time
        modprobe -r nvidia_uvm --first-time
        modprobe -r nvidia_drm --first-time
        modprobe -r nvidia --first-time
        modprobe -r i2c_nvidia_gpu --first-time
        modprobe -r nvidiafb --first-time

        #rmmod xhci_pci #remove these via driver unbind since they persist #2
        #rmmod snd_hda_intel  #remove these via driver unbind since they persist #3

        #modprobe -r drm_kms_helper drm
        

        sleep 1
        # Detach GPU devices from host, detached succesfully without  removing modules
        virsh nodedev-detach $VIRSH_GPU_VIDEO
        
        virsh nodedev-detach $VIRSH_GPU_AUDIO
        
        virsh nodedev-detach $VIRSH_GPU_USB
        
        virsh nodedev-detach $VIRSH_GPU_SB
        
        # Load vfio module
        
        #modprobe vfio --first-time
        #modprobe vfio_iommu_type1 --first-time
        #modprobe vfio-pci --first-time

        # hoeft niet eens 
         echo "vfio-pci" >  /sys/bus/pci/devices/0000\:08\:00.0/driver_override
         echo "vfio-pci" >  /sys/bus/pci/devices/0000\:08\:00.1/driver_override
         echo "vfio-pci" >  /sys/bus/pci/devices/0000\:08\:00.2/driver_override
         echo "vfio-pci" >  /sys/bus/pci/devices/0000\:08\:00.3/driver_override
       

      '';
      mode = "0755";
    };

    "libvirt/hooks/qemu.d/win10/release/end/stop.sh" = {
      text =
      ''
        #!/run/current-system/sw/bin/bash

        # Debugging
        exec 19>/home/howie/Desktop/stoplogfile
        BASH_XTRACEFD=19
        set -x

        # Load variables we defined
        source "/etc/libvirt/hooks/kvm.conf"

        # first unbind, then unload module?
        echo "0000:08:00.0" > /sys/bus/pci/devices/0000\:08\:00.0/driver/unbind
        sleep 1
        echo "0000:08:00.1" > /sys/bus/pci/devices/0000\:08\:00.1/driver/unbind
        sleep 1
        echo "0000:08:00.2" > /sys/bus/pci/devices/0000\:08\:00.2/driver/unbind
        sleep 1
        echo "0000:08:00.3" > /sys/bus/pci/devices/0000\:08\:00.3/driver/unbind
        sleep 1
  
        modprobe -r vfio --first-time
        #modprobe -r vfio_iommu_type1 --first-time # is included in first
        modprobe -r vfio-pci --first-time

        # Attach GPU devices from host
        virsh nodedev-reattach $VIRSH_GPU_VIDEO
        virsh nodedev-reattach $VIRSH_GPU_AUDIO
        virsh nodedev-reattach $VIRSH_GPU_USB
        virsh nodedev-reattach $VIRSH_GPU_SB

        # Read nvidia x config /query/reset
        nvidia-smi -q
        #nvidia-smi -r
       
        #echo "nvidia" >  /sys/bus/pci/devices/0000\:08\:00.0/driver_override

        sleep 5

        # Load NVIDIA kernel modules
     
        modprobe nvidia --first-time
        modprobe nvidia_drm --first-time
        modprobe i2c_nvidia_gpu --first-time
        modprobe nvidiafb --first-time
        modprobe nvidia_modeset  --first-time
        modprobe nvidia_uvm --first-time
        
        #modprobe xhci_pci  --first-time
        #modprobe snd_hda_intel  --first-time
        #modprobe drm --first-time
        #modprobe drm_kms_helper --first-time
        
        # Avoid race condition

        sleep 3

        # Bind EFI Framebuffer
        echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind

        # Bind VTconsoles
        echo 1 > /sys/class/vtconsole/vtcon0/bind
        echo 1 > /sys/class/vtconsole/vtcon1/bind

        # Start display manager
        systemctl restart display-manager.service

        # Return host to all cores
        # systemctl set-property --runtime -- user.slice AllowedCPUs=0-12
        # systemctl set-property --runtime -- system.slice AllowedCPUs=0-12
        # systemctl set-property --runtime -- init.scope AllowedCPUs=0-12

        # Change to powersave governor
        echo powersave | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
      '';
      mode = "0755";
    };

    "libvirt/vgabios/patch.rom".source = /home/howie/Desktop/Sync/Files/Linux_Config/symlinks/patch.rom;
  };
}