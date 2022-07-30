{ config, pkgs, ... }:

{

    virtualisation = {
        libvirtd.enable = true;
        docker = {
            enable = true;
            enableOnBoot = false;
        
        };
        #spiceUSBRedirection.enable = true;
    };

    users.users.howie.extraGroups = [ "docker" ];


    # virtualisation.docker.enable = true;
    #virtualisation.podman = {      enable = true;      # Create a`docker` alias for podman, to use it as a drop-in replacement
     # dockerCompat = true;
    #};
    virtualisation.oci-containers.backend = "docker";


}
