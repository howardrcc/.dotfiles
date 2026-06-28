{ config, pkgs, ...}:

{


  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/cbc30736-f25b-4712-904e-8e91d6654b56";
    fsType = "btrfs";
    options = [ "defaults" "nofail" "compress=zstd" ];
  };

  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/7d6c97f1-91ec-418e-9ac0-afd12754e490";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };


}
