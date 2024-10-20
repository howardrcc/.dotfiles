 
{ config, pkgs, ... }:

{
virtualisation.oci-containers.containers.test = {

        image = "docker/getting-started";
        autoStart = true;
        #cmd = ["--name pihole1"];
#        extraOptions = ["--network=host"];
 #       user = "howie:howie";
        ports = [
            "82:80/tcp"
            ];
      };

}
