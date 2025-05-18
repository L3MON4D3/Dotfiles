{ config, lib, pkgs, machine, data, ... }:

let
  machine_lan_address = data.network.lan.peers.${machine}.address;
in {
  services.immich = {
    enable = true;
    port = lib.toInt data.ports.immich;
    host = machine_lan_address;
  };

  services.caddy.extraConfig = ''
    http://immich, http://immich.internal, http://immich.${machine} {
      reverse_proxy http://${machine_lan_address}:${data.ports.immich}
    }
  '';

  services.postgresql = {
    ensureUsers = [ {
      name = "restic";
    }];
    authentication = ''
      local immich restic peer
    '';
  };
  # run after immich sets up its database.
  systemd.services.postgresql.postStart = lib.mkAfter ''
    $PSQL immich -tAc 'GRANT CONNECT ON DATABASE immich TO restic' || true
    $PSQL immich -tAc 'GRANT SELECT ON ALL TABLES IN SCHEMA public TO restic' || true
    $PSQL immich -tAc 'GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO restic' || true
  '';

  # override settings from service-file.
  systemd.tmpfiles.settings.immich = lib.mkForce {
    ${config.services.immich.mediaLocation} = {
      e = {
        user = "immich";
        group = "immich";
        mode = "0750";
      };
    };
  };
  systemd.services.immich-server.serviceConfig.UMask = lib.mkForce 0027;
  systemd.services.immich-machine-learning.serviceConfig.UMask = lib.mkForce 0027;

  l3mon.restic.extraGroups = [ "immich" ];
  l3mon.restic = {
    dailyRequiredServices = [ "postgresql.service" ];
    specs.immich = {
      backupStopResumeServices = ["immich-server.service"];
      backupDaily = {
        runtimeInputs = [ config.services.postgresql.package ];
        text = ''
          cd ${config.services.immich.mediaLocation}
          restic backup --tag=immich-data --skip-if-unchanged=true -- library
          pg_dump immich | restic backup --tag=immich-db --skip-if-unchanged=true --stdin --stdin-filename=immich.db
        '';
      };
      forget = {
        text = ''
          restic forget --tag=immich-data --group-by=tag --keep-daily=7 --keep-monthly=12
          restic forget --tag=immich-db --group-by=tag --keep-daily=7 --keep-monthly=12
        '';
      };
    };
  };
}
