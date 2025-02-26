{ config, lib, pkgs, machine, data, ... }:

with lib;
let
  cfg = config.l3mon.restic;
in {
  options.l3mon.restic = {
    enable = mkEnableOption (lib.mdDoc "Enable backups via restic.");
    enable_server = mkEnableOption (lib.mdDoc "Enable restic-rest-server.");

    specs = mkOption {
      type = types.attrs;
      description = lib.mdDoc ''
        Attrset, maps unique names to another attrset with valid keys
        backupDaily, backup15min, and forget.  
        These have to contain arguments valid for the attrset of
        writeShellApplication, and will be provided Env-args to call restic.
      '';
      default = [];
    };
    
    repo = mkOption {
      type = types.raw;
      description = lib.mdDoc "Attrset with keys `location` and `passwordFile`";
    };

    dailyBackupTime = mkOption {
      type = types.str;
      description = "When to do the daily backup. Specify as second part of systemd-timer OnCalendar-string, eg. 20:00:00";
      default = "20:00:00";
    };
    dailyRequiredServices = mkOption {
      type = with types; listOf str;
      description = "Services that have to be running before restic-daily can do its backup. Useful for mysqld.";
      default = [];
    };

    wrapper = mkOption {
      type = types.package;
      description = ''
        A wrapper that exposes a `l3mon-restic`-command and automatically
        operates on the repository specified in this submodule.
      '';
      readOnly = true;
    };

    doRepoMaintenance = mkEnableOption "Whether to perform prune and check on restic repo.";

    maintenanceExtra = mkOption {
      type = with types; listOf attrs;
      description = lib.mdDoc "Additional attrs passed to pkgs.writeShellApplication and executed during daily backup tasks.";
    };

    extraGroups = mkOption {
      type = with types; listOf str;
      description = lib.mdDoc "Additional groups the backup-user should belong to. Use this to grant read-access to the backup-service.";
      default = [];
    };
  };

  config = mkMerge [
    (mkIf cfg.enable (let
      specs = cfg.specs;
      shellApplicationSpecToCaller = spec: pkgs.writeShellApplication (
          spec // {
            name = "run";
            runtimeInputs = (if spec ? runtimeInputs then spec.runtimeInputs else []) ++ [ pkgs.restic ];
          } ) + "/bin/run";

      specs_to_scriptlist = attr_name: (map (
        name: let
          namespec = specs."${name}";
          bd = namespec."${attr_name}";
        in shellApplicationSpecToCaller (bd // {
          text = ''
            echo Backing up ${name}
            ${optionalString (namespec ? "backupStopResumeServices") "${config.security.wrapperDir}/sudo ${pkgs.systemd}/bin/systemctl stop ${builtins.toString namespec.backupStopResumeServices}"}
            ${bd.text}
            ${optionalString (namespec ? "backupStopResumeServices") "${config.security.wrapperDir}/sudo ${pkgs.systemd}/bin/systemctl start ${builtins.toString namespec.backupStopResumeServices}"}
          '';
        })
      ) (builtins.filter (name: specs."${name}" ? "${attr_name}") (builtins.attrNames specs)));

      remote_repo = (builtins.substring 0 1 cfg.repo.location) != "/";
      envFile = pkgs.writeTextFile {
        name = "restic-env";
        text = ''
          RESTIC_CACHE_DIR=/var/cache/restic
          RESTIC_PASSWORD_FILE=${cfg.repo.passwordFile}
          RESTIC_REPOSITORY=${cfg.repo.location}
        '';
      };
      common_unit_opts = {
        requires = if remote_repo then [ "network-online.target" ] else [];
        after = if remote_repo then [ "network-online.target" ] else [];
        unitConfig.RequiresMountsFor = if !remote_repo then [ cfg.repo.location ] else [];
        serviceConfig = {
          EnvironmentFile = [ "${envFile}" ];
          Type = "oneshot";
          User = "restic";
          # This is set in the nixos-restic-service, and I don't think it's actually used... (does not seem like restic uses this directory)
          # RuntimeDirectory = "restic";
          CacheDirectory = "restic";
          # make sure permissions are correct before backup.
          # Maybe this is excessive.... But it's an easy way to enforce permissions on certain directories.
          ExecStartPre = "+${pkgs.systemd}/bin/systemd-tmpfiles --create";
        };
      };
    in {
      users.users.restic = {
        isSystemUser = true;
        uid = config.ids.uids.restic;
        extraGroups = cfg.extraGroups;
        group = "restic";
      };
      users.groups.restic.gid = config.ids.uids.restic;

      environment.systemPackages = with pkgs; [
        config.l3mon.restic.wrapper
      ];
      environment.shellAliases = {
        lr = "l3mon-restic";
      };

      security.sudo = {
        extraRules = [{
          commands = let
            start_stop_services = builtins.catAttrs "backupStopResumeServices" (builtins.attrValues specs);
          in
            (map (service_names: {
              command = "${pkgs.systemd}/bin/systemctl start ${builtins.toString service_names}, ${pkgs.systemd}/bin/systemctl stop ${builtins.toString service_names}";
              options = [ "NOPASSWD" ];
            }) start_stop_services);
          groups = [ "restic" ];
        }];
      };


      # enable restics allowOther-flag, so any user (eg simon) can access a
      # fuser-mounted directory owned by restic.
      programs.fuse.userAllowOther = true;

      systemd = let
        script_15min = concatStringsSep "\n" (specs_to_scriptlist "backup15min");
        script_daily = concatStringsSep "\n" (
          (specs_to_scriptlist "backupDaily") ++
          (specs_to_scriptlist "forget") ++
          (if cfg.doRepoMaintenance then [
              ''
                restic prune
                restic check --read-data
              ''
            ] ++ map shellApplicationSpecToCaller cfg.maintenanceExtra else []));
            

        enable_15min = script_15min != "";
        enable_daily = script_daily != "";
      in (
        mkMerge [
          (if enable_15min then {
            timers."restic-15min" = {
              enable = true;
              wantedBy = [ "timers.target" ];
              timerConfig = {
                OnBootSec = "15min";
                OnUnitInactiveSec="15min";
                Unit = "restic-15min.service";
              };
            };
            services."restic-15min" = common_unit_opts // {
              script = script_15min;
            };
          } else {})

          (if enable_daily then {
            timers."restic-daily" = {
              enable = true;
              wantedBy = [ "timers.target" ];
              timerConfig = {
                Persistent = true;
                OnCalendar = "*-*-* " + cfg.dailyBackupTime;
                Unit = "restic-daily.service";
              };
            };

            # mkMerge because we have multiple after,requires-keys, and // would
            # override.
            services."restic-daily" = lib.mkMerge [
              common_unit_opts
              {
                after = cfg.dailyRequiredServices;
                requires = cfg.dailyRequiredServices;

                path = [ pkgs.restic ];
                script = script_daily;
              }
            ];
          } else {})

          (if !remote_repo then {
            tmpfiles.rules = [
              "d  ${cfg.repo.location}    0755    restic  restic"
            ];
          } else {})
        ]
      );

      l3mon.restic.wrapper = pkgs.writeShellApplication {
        name = "l3mon-restic";
        runtimeInputs = [ pkgs.restic pkgs.coreutils pkgs.bashInteractive ];
        text = ''
          set -a
          # shellcheck disable=SC1091
          source ${envFile}
          if [ $# == 1 ] && [ "$1" == "mount" ]; then
            dir=$(mktemp -d)
            sudo chown restic:restic "$dir"
            sudo chmod 777 "$dir"
            sudo -E -u restic restic mount "$dir" --allow-other &
            pid=$!
            sleep 1.4
            pushd "$dir"
            bash
            popd
            kill -SIGINT "$pid"
            wait
          else
            sudo -E -u restic restic "$@"
          fi
        '';
      };
    }))
    (mkIf cfg.enable_server (let
      port = data.ports.restic-rest-server;
      machine_lan_address = data.network.lan.peers.${machine}.address;
    in {
      services.restic.server = {
        enable = true;
        listenAddress = "0.0.0.0:${port}";
        dataDir = "/srv/restic";
        extraFlags = [ "--no-auth" ];
      };
      services.caddy.extraConfig = ''
        http://restic, http://restic.internal, http://restic.${machine} {
          reverse_proxy http://${machine_lan_address}:${port}
        }
      '';
    }))
  ];
}
