 { config, pkgs, ... }:

{
 services.grafana= {
    enable = true;
    domain = "grafana.box";
    addr = "0.0.0.0";
    port = 3000;
    smtp = {
        user="howard@t-mobilethuis.nl";
        passwordFile="/grafana/wpw.txt";
        host="smtp.t-mobilethuis.nl:587";
        enable=true;
        fromAddress="howardchingchung@gmail.com";
    };
};
 
 # nginx reverse prox
services.nginx = {
	  enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
};

  services.nginx.virtualHosts."grafana.box" = {
    locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
    };
  };

  services.prometheus = {
    enable = true;
    port = 9009;
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
        job_name = "ryzen";
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
    {
        job_name = "htpcnix";
        static_configs = [{
          targets = [ "192.168.1.133:9002" ];
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
        job_name= "teku-htpc";
        scrape_timeout= "10s";
        metrics_path="/metrics";
        scheme= "http";
        static_configs = [{
          targets = ["192.168.1.133:8008"];
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
		 {
				 job_name="geth node";
         scrape_interval="15s";
         scrape_timeout="10s";
         metrics_path="/debug/metrics/prometheus";
         static_configs= [{
           targets= ["192.168.1.133:6060"];
         }];
      }

        {
        job_name= "besu_htpc";
        scrape_interval="15s";
        scrape_timeout="10s";
        metrics_path="metrics";
        scheme= "http";
        static_configs = [{
          targets = ["192.168.1.133:9545"];
   #       targets = ["localhost:9091"];
          }];
     }

    ];
  };
}
