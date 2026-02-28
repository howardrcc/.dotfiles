{ config, pkgs, ...}:

{


  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/cbc30736-f25b-4712-904e-8e91d6654b56";
    fsType = "btrfs";
    options = [ "defaults" "nofail" "compress=zstd" ];
  };

  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/b558a669-86ea-438f-b568-058f2a3ac45f";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };


}
