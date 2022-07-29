 { config, pkgs, ... }:

{
 services.grafana= {
    enable = true;
    domain = "grafana.box";
    addr = "127.0.0.1";
    port = 3000;
    smtp = {
        user="howard@t-mobilethuis.nl";
        passwordFile="/grafana/wpw.txt";
        host="smtp.t-mobilethuis.nl:587";
        enable=true;
        fromAddress="howardchingchung@gmail.com";
    };
};

 # nginx reverse proxy
  services.nginx.virtualHosts.${config.services.grafana.domain} = {
    locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
        proxyWebsockets = true;
    };
  };

  services.prometheus = {
    enable = true;
    port = 9001;
  };

  services.prometheus = {
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
    scrapeConfigs = [
      {
        job_name = "chrysalis";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }

      {    
        job_name= "teku-dev";
        scrape_timeout= "10s";
        metrics_path="/metrics";
        scheme= "http";
        static_configs = [{
          targets = ["localhost:8008"];
          }];
     }

     {
        job_name= "besu";
        scrape_interval="15s";
        scrape_timeout="10s";
        metrics_path="metrics";
        scheme= "http";
        static_configs = [{
          targets = ["localhost:9545"];
   #       targets = ["localhost:9091"];
          }];
     }

    ];
  };
}
