{ config, lib, pkgs, machine, data, ... }:

with lib;
let
  statedir = "/var/lib/radarr";
  wg_network = data.network.wireguard_mullvad_de;
  wg_machine_conf = wg_network."${machine}";
  port = wg_machine_conf.local_service_ports.radarr;
  conf = pkgs.writeTextFile {
    name = "conf";
    # $RADARR_APIKEY is provided via envsubst.
    text = ''
      <Config>
        <BindAddress>*</BindAddress>
        <Port>${port}</Port>
        <SslPort>9898</SslPort>
        <EnableSsl>False</EnableSsl>
        <LaunchBrowser>False</LaunchBrowser>
        <AuthenticationMethod>Forms</AuthenticationMethod>
        <Branch>master</Branch>
        <LogLevel>info</LogLevel>
        <SslCertPath></SslCertPath>
        <SslCertPassword></SslCertPassword>
        <UrlBase></UrlBase>
        <InstanceName>Radarr</InstanceName>
        <UpdateMechanism>External</UpdateMechanism>
        <AuthenticationRequired>DisabledForLocalAddresses</AuthenticationRequired>
        <ApiKey>''${RADARR_API_KEY}</ApiKey>
      </Config>
    '';
  };
in
{
  config = {
    # reset settings to default, insert api-key.
    system.activationScripts = {
      radarr = {
        text = ''
          install -d -o media -g media ${statedir}
          source /var/secrets/radarr_env
          RADARR_API_KEY=$RADARR_API_KEY ${pkgs.envsubst}/bin/envsubst -i ${conf} -o ${statedir}/config.xml
          chown media:media ${statedir}/config.xml
        '';
      };
    };

    systemd.services.radarr_de = config.l3mon.network_namespaces.mkNetnsService wg_network {
      enable = true;
      description = "Run radarr in network namespace de";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "exec";
      };
      serviceConfig = {
        User="media";
        Group="media";
      };
      script = ''
        ${pkgs.radarr}/bin/Radarr -data=${statedir}
      '';
    };
    systemd.tmpfiles.rules = [
      "d ${statedir} 0755 media media"
    ];
    
    services.nginx.virtualHosts.radarr = {
      serverName = "radarr radarr.${machine}";
      locations = {
        "/" = {
          proxyPass = "http://${wg_machine_conf.local_address}:${port}";
          recommendedProxySettings = true;
          proxyWebsockets = true;
        };
      };
    };

    l3mon.restic.specs.radarr = {
      backupDaily = {
        text = ''
          cd ${statedir}
          restic backup --tag=radarr --skip-if-unchanged=true radarr.db
        '';
      };
      forget = {
        # maybe too much?
        text = ''
          restic forget --tag=radarr --group-by=tag --keep-daily=7 --keep-monthly=12
        '';
      };
    };
  };
}
