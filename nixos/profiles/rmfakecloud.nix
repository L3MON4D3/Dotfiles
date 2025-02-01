{ config, lib, pkgs, machine, data, ... }:

let 
  rmfakecloud = pkgs.rmfakecloud;
  statedir = "/var/lib/rmfakecloud";
  secret_key_env_file = "/var/secrets/rmfakecloud_env";
  machine_lan_address = data.network.lan.peers.${machine}.address;
  port = data.ports.rmfakecloud;
  userprofile = pkgs.writeTextFile {
    name = "userprofile";
    text = ''
      id: admin
      email: admin
      emailverified: true
      password: $argon2id$v=19$m=3072,t=5,p=4$gHlHfdj/wAQPt7LtY50Hdg$KdZUvMUq4VOewZZdI/g/slOVoLrCaeRQTy8xTA16bzU
      name: ""
      nickname: ""
      givenname: ""
      familyname: ""
      createdat: 2025-02-01T23:04:05.140093075+01:00
      updatedat: 2025-02-01T23:04:05.140093335+01:00
      isadmin: true
      sync15: true
      additionalscopes: []
      integrations:
        - provider: localfs
          id: 5040f9b0-c6b4-4584-a646-fed43fd91e99
          name: local
          path: /srv/remarkable-local
    '';
  };
  rmfakecloud_id = data.ids.rmfakecloud;
in {
  users.users.rmfakecloud = {
    isSystemUser = true;
    uid = rmfakecloud_id;
    group = "rmfakecloud";
  };
  users.groups.rmfakecloud.gid = rmfakecloud_id;

  systemd.services.rmfakecloud = {
    description = "Self-hosted cloud for remarkable.";

    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    environment = {
      PORT = port;
      DATADIR = statedir;
      LOGLEVEL = "debug";
      STORAGE_URL = "http://rmfakecloud.internal";
    };
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      EnvironmentFile = secret_key_env_file;

      User = "rmfakecloud";
      Group = "rmfakecloud";

      # protections.
      PrivateDevices = true;
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      CapabilityBoundingSet = [ "" ];
      DevicePolicy = "closed";
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      ProtectClock = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectProc = "invisible";
      ProcSubset = "pid";
      RemoveIPC = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      WorkingDirectory = statedir;
      StateDirectory = baseNameOf statedir;
      UMask = "0027";
    };
    script = "${rmfakecloud}/bin/rmfakecloud";
  };

  services.caddy.extraConfig = ''
    http://rmfakecloud, http://rmfakecloud.internal, http://rmfakecloud.${machine} {
      reverse_proxy http://${machine_lan_address}:${port}
    }
  '';

  systemd.tmpfiles.rules = [
    "d ${statedir}             0750 rmfakecloud rmfakecloud"
    "d ${statedir}/users       0750 rmfakecloud rmfakecloud"
    "d ${statedir}/users/admin 0750 rmfakecloud rmfakecloud"
    "A ${statedir} -    -           -           - g:rmfakecloud:rX"
    "d /srv/remarkable-local   0750 rmfakecloud rmfakecloud"
  ];

  # make .userprofile readonly, allow editing only through ${userprofile}.
  system.activationScripts = {
    rmfakecloud_admin = {
      text = ''
        cp ${userprofile} ${statedir}/users/admin/.userprofile || true
        chown rmfakecloud:rmfakecloud ${statedir}/users/admin/.userprofile
        chmod 440 ${statedir}/users/admin/.userprofile
      '';
    };
  };

  fileSystems."/srv/nfs/remarkable-local" = {
    depends = ["/mnt/glacier"];
    device = "/srv/remarkable-local";
    options = [ "_netdev" "bind" ];
  };
  # owner is rmfakecloud.
  services.nfs.server.exports = ''
    /srv/nfs/remarkable-local 192.168.178.0/24(rw,all_squash,anonuid=${toString rmfakecloud_id},anongid=${toString rmfakecloud_id})
  '';

  users.users.restic.extraGroups = [ "rmfakecloud" ];
  l3mon.restic.dailyStopResumeServices = [ "rmfakecloud.service" ];
  l3mon.restic.specs.rmfakecloud = {
    # create two tags, one for files and one for the database-backup.
    # I don't think both can be put into one snapshot easily if I want to use
    # the `--stdin`-option.
    # This is fine though :)
    backupDaily = {
      text = ''
        cd ${statedir}
        restic backup --tag=rmfakecloud --skip-if-unchanged=true -- users/admin/sync/
      '';
      runtimeInputs = [ config.services.mysql.package ];
    };
    forget = {
      text = ''
        restic forget --tag=rmfakecloud --group-by=tag --keep-daily=7 --keep-monthly=12
      '';
    };
  };
}
