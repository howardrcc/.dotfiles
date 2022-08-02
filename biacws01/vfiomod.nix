{ lib, pkgs, config, ... }:
with lib;
let cfg = config.virtualisation.vfio;
in {
  options.virtualisation.vfio = {
    enable = mkEnableOption "VFIO Configuration";
    IOMMUType = mkOption {
      type = types.enum [ "intel" "amd" ];
      example = "intel";
      description = "Type of the IOMMU used.";
    };
    devices = mkOption {
      type = types.listOf (types.strMatching "[0-9a-f]{4}:[0-9a-f]{4}");
      default = [ ];
      example = [ "10de:1b80" "10de:10f0" ];
      description = "PCI IDs of devices to bind to vfio-pci.";
    };
    disableEFIfb = mkOption {
      type = types.bool;
      default = false;
      description = "Disables the usage of the EFI framebuffer on boot.";
    };
    blacklistNvidia = mkOption {
      type = types.bool;
      default = false;
      description = "Add Nvidia GPU modules to blacklist.";
    };
    blacklistAMD = mkOption {
      type = types.bool;
      default = false;
      description = "Add AMD GPU modules to blacklist.";
    };
    ignoreMSRs = mkOption {
      type = types.bool;
      default = false;
      description = "Enables or disables kvm guest access to model-specific registers.";
    };
    enableNestedVirt = mkOption {
      type = types.bool;
      default = false;
      description = "Enables nested virtualization.";
    };
    applyACSpatch = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If set, the following things will happen:
          - The ACS override patch is applied
          - Applies the i915-vga-arbiter patch
          - Adds pcie_acs_override=downstream to the command line
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelParams = (if cfg.IOMMUType == "intel" then [
      "intel_iommu=on"
      "intel_iommu=igfx_off"
    ] else
      [ "amd_iommu=on" ]) ++ (optional (builtins.length cfg.devices > 0)
        ("vfio-pci.ids=" + builtins.concatStringsSep "," cfg.devices))
      ++ (optional cfg.applyACSpatch
        "pcie_acs_override=downstream,multifunction")
      ++ (optionals cfg.disableEFIfb [ "video=efifb:off" "video=vesafb:off" "quiet" ])
      ++ (optional cfg.ignoreMSRs "kvm.ignore_msrs=1");

    boot.kernelModules = [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];

    boot.initrd.kernelModules =
      [ "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];

    boot.blacklistedKernelModules =
      (optionals cfg.blacklistNvidia [ "nvidia" "nouveau" ])
      ++ (optionals cfg.blacklistAMD [ "amdgpu" "radeon" ]);
    
    boot.extraModprobeConfig = if cfg.enableNestedVirt then 
      "options kvm_${cfg.IOMMUType} nested=1"
      else "";

    boot.kernelPatches = optionals cfg.applyACSpatch [
      {
        name = "add-acs-overrides";
        patch = pkgs.fetchurl {
          name = "add-acs-overrides.patch";
          url =
            "https://aur.archlinux.org/cgit/aur.git/plain/add-acs-overrides.patch?h=linux-vfio&id=c580c0ca71ad7f64191f74606eaff7ab757f0700";
          sha256 = "1hhbm9fmc69h1z75gbq311cdkvv1rcmivzxlqmmgkgk646jz8lh3";
        };
      }
      {
        name = "i915-vga-arbiter";
        patch = pkgs.fetchurl {
          name = "i915-vga-arbiter.patch";
          url =
            "https://aur.archlinux.org/cgit/aur.git/plain/i915-vga-arbiter.patch?h=linux-vfio&id=d1143eaeb4ce71590c61e8a9b281037ae5c87fa8";
          sha256 = "1kscqwrjm9kxhavyq92mhxgr5jjq2id24682hkqc5kjj5f82jjh9";
        };
      }
    ];
  };
}