{ config, lib, pkgs, pkgs-unstable, machine, data, ... }:

with lib;
let
  statedir = "/var/lib/jackett";
  wg_network = data.network.wireguard_mullvad_de;
  wg_machine_conf = wg_network.peers."${machine}";
  port = data.ports.jackett;
  jackett_pkg = pkgs-unstable.jackett.overrideAttrs (old: {
    postFixup = old.postFixup + ''
      cp ${./1337x_qxr.yml} $out/lib/jackett/Definitions/
    '';
  });
  # don't care about exposing api key, just keep it stable.
  # UpdateDisabled is less powerful than --NoUpdates
  # (https://github.com/Jackett/Jackett/blob/master/src/Jackett.Common/Services/UpdateService.cs),
  # so make sure to pass that later on.
  jackett_conf = pkgs.writeTextFile {
  name = "conf";
  text = ''
    {
      "Port": ${toString port},
      "LocalBindAddress": "127.0.0.1",
      "AllowExternal": true,
      "AllowCORS": false,
      "APIKey": "atfbt2czwryi2asmauh3ugv19cm6tkea",
      "AdminPassword": null,
      "InstanceId": "14ay7aa5sugwb2765liy7fvea0z7lrxulwfkny82iwnlc6iktjewit367y4gsxlq",
      "BlackholeDir": null,
      "UpdateDisabled": true,
      "UpdatePrerelease": true,
      "BasePathOverride": null,
      "BaseUrlOverride": null,
      "CacheEnabled": true,
      "CacheTtl": 2100,
      "CacheMaxResultsPerIndexer": 1000,
      "FlareSolverrUrl": null,
      "FlareSolverrMaxTimeout": 55000,
      "OmdbApiKey": null,
      "OmdbApiUrl": null,
      "ProxyType": 0,
      "ProxyUrl": null,
      "ProxyPort": null,
      "ProxyUsername": null,
      "ProxyPassword": null,
      "ProxyIsAnonymous": true
    }
  '';
  };
in
{
  config = {
    system.activationScripts = {
      jackett = {
        text = ''
          install -d -o jackett -g jackett ${statedir}
          install -D -o jackett -g jackett ${jackett_conf} ${statedir}/ServerConfig.json
        '';
      };
    };

    users.users.jackett = {
      isSystemUser = true;
      uid = config.ids.uids.jackett;
      group = "jackett";
    };
    users.groups.jackett.gid = config.ids.uids.jackett;

    systemd.services.jackett_de = config.l3mon.network_namespaces.mkNetnsService wg_network {
      enable = true;
      description = "Run jackett in network namespace de";
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "exec";
        User = "jackett";
        Group = "jackett";
        StateDirectory = "jackett";
        # Sandboxing
        CapabilityBoundingSet = [
          "CAP_NET_BIND_SERVICE"
        ];
        ExecPaths = [
          "${builtins.storeDir}"
        ];
        LockPersonality = true;
        NoExecPaths = [
          "/"
        ];
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@clock"
          "~@cpu-emulation"
          "~@debug"
          "~@obsolete"
          "~@reboot"
          "~@module"
          "~@mount"
          "~@swap"
        ];
      };
      script = ''
        ${jackett_pkg}/bin/Jackett --NoUpdates --DataFolder $STATE_DIRECTORY;
      '';
    };

    services.caddy.extraConfig = ''
      http://jackett, http://jackett.internal, http://jackett.${machine} {
        reverse_proxy http://${wg_machine_conf.local.address}:${toString port}
      }
    '';
    
    l3mon.restic.extraGroups = ["jackett"];
    l3mon.restic.specs.jackett = {
      backupDaily = {
        text = ''
          cd ${statedir}
          restic backup --tag=jackett --skip-if-unchanged=true ServerConfig.json Indexers/
        '';
      };
      forget = {
        text = ''
          restic forget --tag=jackett --group-by=tag --keep-daily=7 --keep-monthly=12
        '';
      };
    };
  };
}
