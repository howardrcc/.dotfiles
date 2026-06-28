{ config, pkgs, ... }:

{
  services.unifi.enable = true;
  services.unifi.unifiPackage = pkgs.unifiCustom;      
  services.unifi.openFirewall = true;
}
