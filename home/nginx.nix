{ config, pkgs, ... }:

{

    security.acme = {
    acceptTerms = true;
    # Replace the email here!
    defaults.email = "howardchingchung@gmail.com";
};

services.nginx = {
   enable = true;

 # Use recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

 # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

# Setup Nextcloud virtual host to listen on ports
 virtualHosts = {

     "howardcc.duckdns.org" = {
       ## Force HTTP redirect to HTTPS
       forceSSL = true;
       ## LetsEncrypt
       enableACME = true;
    };
  };
};


    }