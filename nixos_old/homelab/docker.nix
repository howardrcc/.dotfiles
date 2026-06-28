{ config, pkgs, ... }:

{

    users.users.howie.extraGroups = [ "docker" ];

    virtualisation.docker.enable = true;
    #virtualisation.podman = {      enable = true;      # Create a`docker` alias for podman, to use it as a drop-in replacement
     # dockerCompat = true;
    #};
    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers.pihole2 = {

        image = "pihole/pihole:latest";
        autoStart = true;
        #cmd = ["--name pihole1"];
#        extraOptions = ["--network=host"];
 #       user = "howie:howie";
        ports = [
            "53:53/tcp"
            "53:53/udp"
            "67:67/udp" # Only required if you are using Pi-hole as your DHCP server
            "81:80/tcp"
            ];
 #       environment = {
  #          TZ = "Europe/Amsterdam";
   #     };

            # Volumes store your data between container upgrades
        volumes = [
            "/home/howie/pihole/etc-pihole:/etc/pihole"
            "/home/howie/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"

        ];
      };


}
