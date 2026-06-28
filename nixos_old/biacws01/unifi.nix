{ config, pkgs, ... }:

{
  services.unifi.enable = true;
  services.unifi.unifiPackage = pkgs.unifi;      
  services.unifi.openFirewall = true;
}
