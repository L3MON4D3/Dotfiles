{ config, lib, l3lib, pkgs, pkgs-unstable, pkgs-ddns-updater-2-7, machine, data, ... }:

let
  conf = pkgs.writeTextFile {
    name = "conf";
    text = builtins.toJSON {
      settings = [
        {
          provider = "porkbun";
          domain = "l3mon4.de,wireguard.l3mon4.de,nix-cache.l3mon4.de,nix-tarballs.l3mon4.de";
          api_key = "$PORKBUN_API_KEY";
          secret_api_key = "$PORKBUN_SECRET_API_KEY";
          ip_version = "ipv4";
          ipv6_suffix = "";
          ttl = 60;
        }
        # {
          # provider = "cloudflare";
          # zone_identifier = "b17b3bd2466d8a209be5bc5e3c88585d";
          # domain = "l3mon4.de";
          # host = "@,wireguard";
          # ip_version = "ipv4";
          # ipv6_suffix = "";
          # ttl = 60;
          # token = "$CF_TOKEN";
        # }
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
    package = pkgs.ddns-updater;
    environment = {
      SERVER_ENABLED="yes";
      CONFIG_FILEPATH = "%d/conf";
      LISTENING_ADDRESS=":${toString data.ports.ddns-updater}";
      RESOLVER_ADDRESS="1.1.1.1:53";
    };
  };
  systemd.services.ddns-updater.serviceConfig.LoadCredential = "conf:${runtime_conf_file}";

  services.caddy.extraConfig = ''
    http://ddns-updater, http://ddns-updater.internal, http://ddns-updater.${machine} {
      reverse_proxy http://localhost:${toString data.ports.ddns-updater}
    }
  '';
}
