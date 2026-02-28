{ config, pkgs, ...}:

{

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/cbc30736-f25b-4712-904e-8e91d6654b56";
    fsType = "btrfs";
    options = [ "defaults" "nofail" "compress=zstd" ];
  };

}
