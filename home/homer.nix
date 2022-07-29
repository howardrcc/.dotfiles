 { config, pkgs, ... }:

{
 virtualisation.oci-containers.containers.homer = {
        image = "b4bz/homer";
        autoStart = true;
        ports = [
            "82:8080"
            ];
        environment ={
          INIT_ASSETS="1";
        };
        volumes =[
            "/home/howie/homer/assets/:/www/assets"
            ];
    };



}
