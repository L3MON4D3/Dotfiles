{ config, lib, pkgs, machine, data, ... }:

with lib;
let
  statedir = "/var/lib/sonarr";
  wg_network = data.network.wireguard_mullvad_de;
  wg_machine_conf = wg_network."${machine}";
  port = wg_machine_conf.local_service_ports.sonarr;
  conf = pkgs.writeTextFile {
    name = "conf";
    # $SONARR_APIKEY is provided via envsubst.
    text = ''
      <Config>
        <BindAddress>*</BindAddress>
        <Port>${port}</Port>
        <SslPort>9898</SslPort>
        <EnableSsl>False</EnableSsl>
        <LaunchBrowser>False</LaunchBrowser>
        <AuthenticationMethod>Forms</AuthenticationMethod>
        <Branch>main</Branch>
        <LogLevel>info</LogLevel>
        <SslCertPath></SslCertPath>
        <SslCertPassword></SslCertPassword>
        <UrlBase></UrlBase>
        <InstanceName>Sonarr</InstanceName>
        <UpdateMechanism>External</UpdateMechanism>
        <AuthenticationRequired>DisabledForLocalAddresses</AuthenticationRequired>
        <ApiKey>''${SONARR_API_KEY}</ApiKey>
      </Config>
    '';
  };
in
{
  config = {
    # reset settings to default, insert api-key.
    system.activationScripts = {
      sonarr = {
        text = ''
          install -d -o media -g media ${statedir}
          source /var/secrets/sonarr_env
          SONARR_API_KEY=$SONARR_API_KEY ${pkgs.envsubst}/bin/envsubst -i ${conf} -o ${statedir}/config.xml
          chown media:media ${statedir}/config.xml
        '';
      };
    };

    # for now, until sonarr is updated to .Net 8, then these can be removed.
    nixpkgs.config.permittedInsecurePackages = [
      "aspnetcore-runtime-6.0.36"
      "aspnetcore-runtime-wrapped-6.0.36"
      "dotnet-sdk-6.0.428"
      "dotnet-sdk-wrapped-6.0.428"
    ];

    systemd.services.sonarr_de = config.l3mon.network_namespaces.mkNetnsService wg_network {
      enable = true;
      description = "Run sonarr in network namespace de";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "exec";
      };
      serviceConfig = {
        User="media";
        Group="media";
      };
      script = ''
        ${pkgs.sonarr}/bin/Sonarr -data=${statedir}
      '';
    };
    systemd.tmpfiles.rules = [
      "d ${statedir} 0755 media media"
    ];
    
    services.nginx.virtualHosts.sonarr = {
      serverName = "sonarr sonarr.${machine}";
      locations = {
        "/" = {
          proxyPass = "http://${wg_machine_conf.local_address}:${port}";
          recommendedProxySettings = true;
          proxyWebsockets = true;
        };
      };
    };

    l3mon.restic.specs.sonarr = {
      backupDaily = {
        text = ''
          cd ${statedir}
          restic backup --tag=sonarr --skip-if-unchanged=true sonarr.db
        '';
      };
      forget = {
        # maybe too much?
        text = ''
          restic forget --tag=sonarr --group-by=tag --keep-daily=7 --keep-monthly=12
        '';
      };
    };
  };
}
