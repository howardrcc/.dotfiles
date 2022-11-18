# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "rpool/nixos";
      fsType = "zfs";
      options = [ "zfsutil" ]; 
    };

  fileSystems."/nix" =
    { device = "rpool/nixos/nix";
      fsType = "zfs";
      options = [ "zfsutil" ]; 
    };

  fileSystems."/home" =
    { device = "rpool/userdata/home";
      fsType = "zfs";
      options = [ "zfsutil" ]; 
    };

  fileSystems."/root" =
    { device = "rpool/userdata/home/root";
      fsType = "zfs";
      options = [ "zfsutil" ]; 
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/38DD-2D6B";
#     { device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S4EWNF0MA34459Z-part3";
      fsType = "vfat";
      options = [ "X-mount.mkdir" ];
    };

#  fileSystems."/eth" =
#    { device = "/dev/disk/by-uuid/182179ea-a124-4c44-a41a-048acb58afdf";
#      fsType = "ext4";
#   };

#  fileSystems."/mnt/ssd" =
#    { device = "/dev/disk/by-id/ata-CT1000MX500SSD1_2211E619D985-part2";
#      fsType = "ext4";
#   };



  swapDevices = [
    { device = "/dev/disk/by-id/nvme-eui.0025385a91b2b633-part2";
      randomEncryption = true;
    }
 ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp4s0.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
