{ config, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "howie";
    #dataDir = "/home/davidak/.syncthing";
    guiAddress = "0.0.0.0:8384";
  };
  
}