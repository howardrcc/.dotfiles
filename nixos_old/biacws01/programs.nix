{ config, pkgs, ...}:

{
	programs.steam.enable= true;
	programs.chromium.enable = true;
	services.tailscale.enable= true;

	environment.systemPackages = [
		pkgs.chromium
	];
	programs.ssh.startAgent = true;
	#services.unifi.enable = true;
	#services.unifi.unifiPackage = pkgs.unifi6;      
	#services.unifi.openFirewall = true;

}
