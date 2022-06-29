{ config, pkgs, ... }:
{

services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
networking.firewall.allowedTCPPorts = [
  5357 # wsdd
];
networking.firewall.allowedUDPPorts = [
  3702 # wsdd
];
services.samba = {
  enable = true;
  securityType = "user";
  extraConfig = ''
    workgroup = WORKGROUP
    server string = home
    netbios name = home
    security = user 
    #use sendfile = yes
    #max protocol = smb2
    # note: localhost is the ipv6 localhost ::1
    hosts allow = 192.168.1.0/24 127.0.0.1 localhost
    hosts deny = 0.0.0.0/0
    guest account = nobody
    map to guest = bad user
  '';
  shares = {
    public = {
      #path = "/home/syncthing/Music";
      path = "/home/howie";
      browseable = "yes";
      "read only" = "no";
      "guest ok" = "yes";
      "create mask" = "0644";
      "directory mask" = "0755";
      "force user" = "howie";
      "force group" = "users";
    };
 
  };
};
}
