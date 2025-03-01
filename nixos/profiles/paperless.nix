{ config, lib, l3lib, pkgs, machine, data, ... }:

let
  machine_lan_address = data.network.lan.peers.${machine}.address;
  port = data.ports.paperless;
in {
  services.paperless = {
    enable = true;

    address = "paperless.internal";
    port = lib.toInt port;

    passwordFile = l3lib.secret "paperless_password";
    settings = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
    };
  };

  fileSystems."/srv/nfs/paperless-consume" = {
    device = "/var/lib/paperless/consume";
    options = [ "bind" ];
  };

  # 315 is id of paperless.
  # make sure client has id 315 for paperless as well, and user belongs to paperless-group.
  services.nfs.server.exports = ''
    /srv/nfs/paperless-consume 192.168.178.0/24(rw,all_squash,anonuid=${builtins.toString config.ids.uids.paperless},anongid=${builtins.toString config.ids.gids.paperless})
  '';

  systemd.tmpfiles.rules = lib.mkAfter [
    "A /var/lib/paperless - - - - g:paperless:rX"
    "Z /var/lib/paperless/index 0750 paperless paperless"
  ];
  l3mon.restic.extraGroups = [ "paperless" ];

  l3mon.restic.specs.paperless = {
    backupStopResumeServices = [
      "paperless-consumer.service"
      "paperless-scheduler.service"
      "paperless-task-queue.service"
      "paperless-web.service"
    ];
    backupDaily = {
      text = ''
        cd /var/lib/paperless
        restic backup --tag=paperless --skip-if-unchanged=true -- media/documents/archive media/documents/originals db.sqlite3 index src-version
      '';
    };
    forget = {
      text = ''
        restic forget --tag=paperless --group-by=tag --keep-daily=7 --keep-monthly=12
      '';
    };
  };

  services.caddy.extraConfig = ''
    http://paperless, http://paperless.internal, http://paperless.${machine} {
      reverse_proxy http://${machine_lan_address}:${port}
    }
  '';
}
