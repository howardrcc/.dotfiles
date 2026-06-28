{ config, pkgs, ... }:
{
  # Boot configuration

  boot = {
    kernelParams = [ "amd_iommu=on" "iommu=pt" ];
#   boot.kernelModules = [ "vfio-pci" ]; #"kvm-intel" 
    kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
    initrd.kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];
    blacklistedKernelModules = ["nouveau"  ]; #"i2c_nvidia_gpu"
 };

# softdep snd_hda_intel pre: vfio-pci 
  boot.extraModprobeConfig = ''
    options vfio_iommu_type1 allow_unsafe_interrupts=1
  '';

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.ovmf.enable = true;
      #qemu.swtpm.enable = false;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu.runAsRoot = true;
      qemu.package = pkgs.qemu_kvm;
      qemu.verbatimConfig = ''
        nvram = [
          "/nix/store/1r7f3dygswsix6vz28ar4yprjzf1zwax-OVMF-202202-fd/FV/OVMF.fd:/nix/store/1r7f3dygswsix6vz28ar4yprjzf1zwax-OVMF-202202-fd/FV/OVMF_VARS.fd"
        ]
  '';

    };
    #vfio = {
    #  enable = true;
    #  IOMMUType = "amd";
    #  devices = [ "10de:1e07" "10de:10f7" "10de:1ad6" "10ec:8125" "10de:1ad7" ];
    #  ignoreMSRs = true;
    #  disableEFIfb = true;
    #  blacklistAMD = true;
    #  enableNestedVirt = false;
    #};
  };

 

 
 #"/nix/store/1r7f3dygswsix6vz28ar4yprjzf1zwax-OVMF-202202-fd/FV/OVMF.fd:/nix/store/1r7f3dygswsix6vz28ar4yprjzf1zwax-OVMF-202202-fd/FV/OVMF_VARS.fd"

  systemd.services.pcscd.enable = false;
  systemd.sockets.pcscd.enable = false;
  programs.dconf.enable = true;

  # VFIO Packages installed
  users.groups.libvirtd.members = [ "root" "howie"];

  environment.systemPackages = with pkgs; [
    virt-manager
    OVMF
    qemu
    pciutils
    #dconf # needed for saving settings in virt-manager
    #libguestfs # needed to virt-sparsify qcow2 files
  ];

}
