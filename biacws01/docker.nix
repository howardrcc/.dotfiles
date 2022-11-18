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
    virtualisation.oci-containers.backend = "docker";

   virtualisation.oci-containers.containers.piholex = {
       image = "pihole/pihole:latest";
       autoStart = true;
       #cmd = ["--name pihole2"];
       #extraOptions = ["--network=host"];
       #user = "howie:users";
       ports = [
           "53:53/tcp"
           "53:53/udp"
           #"67:67/udp" # Only required if you are using Pi-hole as your DHCP server
           "80:80/tcp"
           ];
       volumes = [
           "/home/howie/pihole/etc-pihole:/etc/pihole"
           "/home/howie/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
       ];
     };

#      virtualisation.oci-containers.containers.teku = {
#        image = "consensys/teku:latest";
#        autoStart = false;
#        ports = [
#            "9000:9000/tcp"
#            "9000:9000/udp"
#            "5051:5051"
#            "8008:8008"
#            #metrics
#            ];

#        cmd = [ 
#	    "--config-file=/opt/teku/data/config.yaml"
#	    ];
#        environment ={
#          JAVA_OPTS= "-Xmx8g";
#        };
#        volumes =[
#            "/home/howie/teku:/opt/teku/data"
#            ];
#        dns?
#        networks?
#
#    };
# virtualisation.oci-containers.containers.besu = {
#        image = "hyperledger/besu:latest";
#        autoStart = false;
#        ports = [
#            "8545:8545/tcp"
#            "8546:8546/tcp"
#            "30305:30305"
            #"8551:8551/tcp"
            #"9545:9545/tcp"
#            #metrics
#            ];
#        cmd = [ 
#	    "--config-file=/opt/besu/conf/config.toml"
#        ];
#        environment ={
#          BESU_OPTS="-Xmx12g";
#          };
#	    
#        volumes =[
#            "/home/howie/besu/conf:/opt/besu/conf/"
#            "/home/howie/besu/data:/opt/besu/data/"
#            ];
#
#
#    };





}
