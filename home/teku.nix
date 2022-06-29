 { config, pkgs, ... }:

{
 virtualisation.oci-containers.containers.howie-teku_node-1 = {
        image = "consensys/teku:latest";
        autoStart = false;
        ports = [
            "9000:9000/tcp"
            "9000:9000/udp"
            "5051:5051"
            ];
        cmd = [ 
	    "--config-file=/opt/teku/data/config.yaml"
	    ];
        environment ={
          JAVA_OPTS= "-Xmx4g";
        };
        volumes =[
            "/home/howie/teku:/opt/teku/data"

            ];


    };
    }
