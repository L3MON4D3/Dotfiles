{ config, lib, pkgs, machine, data, ... }:

let
  cfg = {
    spaceDir = "/var/lib/silverbullet-work";
    user = "silverbullet-work";
    group = cfg.user;
    envFile = null;
    listenPort = data.ports.silverbullet_work;
    listenAddress = "127.0.0.1";
    package = config.services.silverbullet.package;
    extraArgs = [];
  };
in {
  users.users.silverbullet-work = {
    isSystemUser = true;
    uid = data.ids.silverbullet-work;
    group = "silverbullet-work";
  };
  users.groups.silverbullet-work.gid = data.ids.silverbullet-work;

  users.users.silverbullet.extraGroups = [ "silverbullet-work" ];

  # adjust umask: allow 
  systemd.services.silverbullet-work = {
    description = "Silverbullet service (work)";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    preStart = lib.mkIf (!lib.hasPrefix "/var/lib/" cfg.spaceDir) "mkdir -p '${cfg.spaceDir}'";
    serviceConfig = {
      Type = "simple";
      User = "${cfg.user}";
      Group = "${cfg.group}";
      UMask = "0007";
      EnvironmentFile = lib.mkIf (cfg.envFile != null) "${cfg.envFile}";
      StateDirectory = lib.mkIf (lib.hasPrefix "/var/lib/" cfg.spaceDir) (
        lib.last (lib.splitString "/" cfg.spaceDir)
      );
      ExecStart =
        "${lib.getExe cfg.package} --port ${toString cfg.listenPort} --hostname '${cfg.listenAddress}' '${cfg.spaceDir}' "
        + lib.concatStringsSep " " cfg.extraArgs;
      Restart = "on-failure";
    };
  };

  l3mon.services.defs.sb-work = {
    cfg = cfg.listenPort;
    networks = with config.lib.l3mon.networks; [ physical.home virtual.home virtual.work ];
  };
  
  systemd.tmpfiles.rules = let
    mainSpaceDir = config.services.silverbullet.spaceDir;
  in lib.mkAfter [
    # correct permissions on main silverbullet instance.
    "d ${mainSpaceDir}/work 2770 silverbullet-work silverbullet-work - -"
    "d ${mainSpaceDir}/public 2770 silverbullet-work silverbullet-work - -"
    "f ${mainSpaceDir}/CONFIG.md 0660 silverbullet-work silverbullet-work - -"

    # shared files.
    "L ${cfg.spaceDir}/work - - - - ${mainSpaceDir}/work"
    "L ${cfg.spaceDir}/public - - - - ${mainSpaceDir}/public"
    "L ${cfg.spaceDir}/CONFIG.md - - - - ${mainSpaceDir}/CONFIG.md"
  ];
}
