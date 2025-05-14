{ config, lib, l3lib, pkgs, machine, data, ... }:

{
  services.samba = {
    enable = true;
    settings = {
      global = {
        "security" = "user";
        "dns proxy" = "no";
        "server role" = "standalone server";
        "server string" = machine;
        "idmap config * : backend" = "tdb";
        "hosts allow" = "192.168.178. 127. 10.0.0.";
        "logging" = "systemd";
        "disable netbios" = "yes";
      };
      christel = {
        "force directory mode" = "02770";
        "path" = "/srv/samba/christel";
        "read only" = "no";
        "valid users" = "christel";
      };
      simon = {
        # make sure group has read-permission.
        "force directory mode" = "02770";
        "path" = "/srv/media";
        "read only" = "yes";
        "valid users" = "simon";
      };
      private = {
        # make sure group has read-permission.
        "force directory mode" = "02770";
        "path" = "/srv/private";
        "read only" = "yes";
        "valid users" = "private";
      };
    };
  };

  # allow <other> access to /srv/samba, for cd.
  systemd.tmpfiles.rules = [
    "d /srv/samba 0755 samba samba"
    "d /srv/samba/christel 0750 christel christel"
  ];

  users.users.samba = {
    isSystemUser = true;
    uid = data.ids.samba;
    group = "samba";
  };
  users.groups.samba.gid = data.ids.samba;

  users.users.christel = {
    isSystemUser = true;
    uid = data.ids.christel;
    group = "christel";
  };
  users.groups.christel.gid = data.ids.christel;

  users.users.private = {
    isSystemUser = true;
    uid = data.ids.private;
    group = "private";
  };
  users.groups.private.gid = data.ids.private;

  system.activationScripts = {
    samba-users = {
      text = (l3lib.assertSecret "smb_passwd_christel") + 
             (l3lib.assertSecret "smb_passwd_simon") + 
             (l3lib.assertSecret "smb_passwd_private") + 
      ''
        echo -ne "$(cat ${l3lib.secret "smb_passwd_christel"})\n$(cat ${l3lib.secret "smb_passwd_christel"})\n" | ${pkgs.samba}/bin/smbpasswd -a christel
        echo -ne "$(cat ${l3lib.secret "smb_passwd_simon"})\n$(cat ${l3lib.secret "smb_passwd_simon"})\n" | ${pkgs.samba}/bin/smbpasswd -a simon
        echo -ne "$(cat ${l3lib.secret "smb_passwd_private"})\n$(cat ${l3lib.secret "smb_passwd_private"})\n" | ${pkgs.samba}/bin/smbpasswd -a private
      '';
    };
  };

  l3mon.restic.extraGroups = [ "christel" "samba" ];
  l3mon.restic.specs.samba = {
    backupDaily = {
      text = ''
        cd /srv/samba
        restic backup --tag=samba-christel --skip-if-unchanged=true -- christel
      '';
    };
    forget = {
      text = ''
        restic forget --tag=samba-christel --group-by=tag --keep-monthly 12 --keep-yearly=unlimited --keep-last=20
      '';
    };
  };
}
