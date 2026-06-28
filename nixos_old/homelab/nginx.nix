{ config, pkgs, ... }:

{

    security.acme = {
        acceptTerms = true;
        # Replace the email here!
        defaults.email = "howardchingchung@gmail.com";
#        defaults.server = "https://127.0.0.1"; 
#        preliminarySelfsigned = true;
    };


services.nginx = {
   enable = true;

 # Use recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
#   httpConfig = "ssl_stapling off;";
 # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

# Setup Nextcloud virtual host to listen on ports
    virtualHosts = {

        "howardcc.duckdns.org" = {
            ## Force HTTP redirect to HTTPS
           forceSSL = true;
           ## LetsEncrypt
            enableACME = true;
#            serverAliases = ["nextcloud.box" "home.local" "home"];
        };



   "pihole.box" =  {
      forceSSL = true;
      sslCertificate = "/etc/ssl/certs/myCA.pem";
      sslCertificateKey = "/etc/ssl/certs/myCA.key";
      
       locations."/" = {
           proxyPass = "http://127.0.0.1:81/admin/";
           proxyWebsockets = true; # needed if you need to use WebSocket
           #extraConfig =
               # required when the target is also TLS server with multiple hosts
           #    "proxy_ssl_server_name on;" +
               # required when the server wants to use HTTP Authentication
           #    "proxy_pass_header Authorization;"
           #    ;
     };
   };

    "dashy.box" = {
       forceSSL = true;
       sslCertificate = "/etc/ssl/certs/myCA.pem";
       sslCertificateKey = "/etc/ssl/certs/myCA.key";
       locations."/" = {
           proxyPass = "http://0.0.0.0:4000";
#           proxyWebsockets = true;
           };
       };


   "unifi.box" = {
       forceSSL = true;
       sslCertificate = "/etc/ssl/certs/myCA.pem";
       sslCertificateKey = "/etc/ssl/certs/myCA.key";
       locations."/" = {
           proxyPass = "https://0.0.0.0:8443";
           proxyWebsockets = true;
           };
       };

   "syncthing.box" = {
       forceSSL = true;
       sslCertificate = "/etc/ssl/certs/myCA.pem";
       sslCertificateKey = "/etc/ssl/certs/myCA.key";
       locations."/" = {
           proxyPass = "http://0.0.0.0:8384";
           proxyWebsockets = true;
           };
       };
  
  }; #vh
}; #nginx
}
