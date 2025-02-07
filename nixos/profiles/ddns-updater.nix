{ config, lib, pkgs, machine, data, ... }:

let
  conf = pkgs.writeTextFile {
    name = "conf";
    text = builtins.toJSON {
      settings = [
        {
          provider = "porkbun";
          domain = "l3mon4.de";
          host = "@";
          api_key = "$PORKBUN_API_KEY";
          secret_api_key = "$PORKBUN_SECRET_API_KEY";
          ip_version = "ipv4";
          ttl = 60;
        }
      ];
    };
  };
  runtime_conf_file = "/run/ddns-updater.conf";
in {
  system.activationScripts = {
    ddns-updater = {
      text =
      (l3lib.assertSecret "porkbun_api_key") +
      (l3lib.assertSecret "porkbun_secret_api_key") +
      ''
        (umask 0077 && \
        PORKBUN_API_KEY=$(cat ${l3lib.secret "porkbun_api_key"}) \
        PORKBUN_SECRET_API_KEY=$(cat ${l3lib.secret "porkbun_secret_api_key"}) \
        ${pkgs.envsubst}/bin/envsubst -i ${conf} -o ${runtime_conf_file})
      '';
    };
  };

  services.ddns-updater = {
    enable = true;
    environment = {
      SERVER_ENABLED="no";
      CONFIG_FILEPATH = "%d/conf";
    };
  };
  systemd.services.ddns-updater.serviceConfig.LoadCredential = "conf:${runtime_conf_file}";
}
