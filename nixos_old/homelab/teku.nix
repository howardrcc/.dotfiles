 { config, pkgs, ... }:

{
 virtualisation.oci-containers.containers.teku = {
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
 virtualisation.oci-containers.containers.besu = {
        image = "hyperledger/besu:latest";
        autoStart = false;
        ports = [
            "8545:8545/tcp"
            "8546:8546/tcp"
            "30303:30303"
            ];
        cmd = [ 
	    "--config-file=/opt/besu/conf/config.toml"
        ];
        environment ={
          BESU_OPTS="-Xmx12g";
          };
	    
        volumes =[
            "/home/howie/besu/conf:/opt/besu/conf/"
            "/home/howie/besu/data:/opt/besu/data/"
            ];


    };



    }
