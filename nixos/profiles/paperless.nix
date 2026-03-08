{ config, lib, l3lib, pkgs, machine, data, ... }:

let
  port = data.ports.paperless;
in {
  services.paperless = {
    enable = true;

    address = "127.0.0.1";
    port = port;
    domain = "paperless.internal";

    passwordFile = l3lib.secret "paperless_password";
    settings = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
      PAPERLESS_URL = "https://${config.l3mon.services.defs.paperless.network_domain}";
    };
  };

  fileSystems."/srv/nfs/paperless-consume" = {
    device = "/var/lib/paperless/consume";
    options = [ "bind" ];
  };

  # 315 is id of paperless.
  # make sure client has id 315 for paperless as well, and user belongs to paperless-group.
  services.nfs.server.exports = toString [
    "/srv/nfs/paperless-consume"
      "192.168.178.0/24(rw,all_squash,anonuid=${toString config.ids.uids.paperless},anongid=${toString config.ids.gids.paperless})"
           "10.0.0.0/24(rw,all_squash,anonuid=${toString config.ids.uids.paperless},anongid=${toString config.ids.gids.paperless})"
  ];

  systemd.tmpfiles.rules = lib.mkAfter [
    "A /var/lib/paperless - - - - g:paperless:rX"
    "Z /var/lib/paperless/index 0750 paperless paperless"
  ];
  l3mon.restic.extraGroups = [ "paperless" ];

  l3mon.restic.specs.paperless = {
    backupStopResumeServices = [
      "paperless-task-queue.service"
      "paperless-consumer.service"
      "paperless-scheduler.service"
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

  l3mon.services.defs.paperless.cfg = port;
}
