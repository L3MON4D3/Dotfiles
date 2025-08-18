{ config, lib, l3lib, pkgs, machine, data, ... }:

with lib;
let
  statedir = "/var/lib/radarr";
  wg_network = data.network.wireguard_mullvad_de;
  wg_machine_conf = wg_network.peers."${machine}";
  port = data.ports.radarr;
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
  radarr-import = pkgs.writeShellApplication {
    name = "radarr-import";
    runtimeInputs = with pkgs; [ coreutils ];
    text = ''
      # shellcheck disable=SC2154
      mkdir -p "$radarr_movie_path"
      # shellcheck disable=SC2154
      cp --reflink=auto "$radarr_sourcepath" "$radarr_moviefile_path"
    '';
  };
in
{
  config = {
    users.users.radarr = {
      isSystemUser = true;
      extraGroups = [ "media" "qbittorrent" ];
      uid = config.ids.uids.radarr;
      group = "radarr";
    };
    users.groups.radarr.gid = config.ids.uids.radarr;

    # reset settings to default, insert api-key.
    system.activationScripts = {
      radarr = {
        text = l3lib.assertSecret "radarr_env" +
        ''
          install -d -o radarr -g radarr ${statedir}
          source ${l3lib.secret "radarr_env"}
          RADARR_API_KEY=$RADARR_API_KEY ${pkgs.envsubst}/bin/envsubst -i ${conf} -o ${statedir}/config.xml
          chown radarr:radarr ${statedir}/config.xml
          ln -sf ${radarr-import}/bin/radarr-import ${statedir}/import.sh
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
        User="radarr";
        Group="radarr";
      };
      script = ''
        ${pkgs.radarr}/bin/Radarr -data=${statedir}
      '';
    };
    systemd.tmpfiles.rules = [
      "d ${statedir} 0750 radarr radarr"
      "Z ${statedir} 0750 radarr radarr"
    ];
    
    services.caddy.extraConfig = ''
      http://radarr, http://radarr.internal, http://radarr.${machine} {
        reverse_proxy http://${wg_machine_conf.local.address}:${port}
      }
    '';

    l3mon.restic.extraGroups = ["radarr"];
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
