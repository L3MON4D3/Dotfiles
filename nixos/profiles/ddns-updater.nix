{ config, lib, l3lib, pkgs, pkgs-unstable, machine, data, ... }:

let
  conf = pkgs.writeTextFile {
    name = "conf";
    text = builtins.toJSON {
      settings = [
        # {
          # provider = "porkbun";
          # domain = "l3mon4.de,wireguard.l3mon4.de";
          # api_key = "$PORKBUN_API_KEY";
          # secret_api_key = "$PORKBUN_SECRET_API_KEY";
          # ip_version = "ipv4";
          # ipv6_suffix = "";
          # ttl = 60;
        # }
        {
          provider = "cloudflare";
          zone_identifier = "b17b3bd2466d8a209be5bc5e3c88585d";
          domain = "l3mon4.de,wireguard.l3mon4.de";
          ip_version = "ipv4";
          ipv6_suffix = "";
          ttl = 60;
          token = "$CF_TOKEN";
        }
      ];
    };
  };
  runtime_conf_file = "/run/ddns-updater.conf";
in {
  system.activationScripts = {
    ddns-updater = {
      text =
      (l3lib.assertSecret "cloudflare-token-l3mon4_de-dns_edit") +
      ''
        (umask 0077 && \
        CF_TOKEN=$(cat ${l3lib.secret "cloudflare-token-l3mon4_de-dns_edit"}) \
        ${pkgs.envsubst}/bin/envsubst -i ${conf} -o ${runtime_conf_file})
      '';
    };
  };

  services.ddns-updater = {
    enable = true;
    package = pkgs-unstable.ddns-updater;
    environment = {
      SERVER_ENABLED="no";
      CONFIG_FILEPATH = "%d/conf";
    };
  };
  systemd.services.ddns-updater.serviceConfig.LoadCredential = "conf:${runtime_conf_file}";
}
