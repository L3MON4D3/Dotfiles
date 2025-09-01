{ config, lib, pkgs, pkgs-unstable, machine, data, ... }:

let
  dav_root = "/srv/http/dav";
in {
  # downside: can only do this once, for other plugins I'll have to make a personal caddy module or something.
  services.caddy.package = pkgs.caddy.withPlugins {
    plugins = ["github.com/mholt/caddy-webdav@v0.0.0-20241008162340-42168ba04c9d"];
    # May have to update this whenever a new nixpkgs is used!
    hash = "sha256-rrkUDnTPKehdKMBDaZdFbaEL2QOsHb3tn6dst2UclE8=";
  };

  services.caddy.globalConfig = ''
    order webdav before file_server
  '';

  services.caddy.extraConfig = ''
    http://webdav, http://webdav.internal, http://webdav.${machine} {
      webdav * {
        root ${dav_root}
        prefix /
      }
      file_server
    }
  '';

  systemd.tmpfiles.rules = [
    "d ${dav_root} 0750 caddy caddy"
    "d ${dav_root}/android-backup 0750 caddy caddy"
    "d ${dav_root}/media 0755"
  ];
  # for clients: nfs-mount these shares.
  fileSystems."${dav_root}/media" = {
    device = "/srv/media/";
    options = [ "bind" ];
  };

  l3mon.restic.extraGroups = [ "caddy" ];
  l3mon.restic.specs.webdav = {
    backupDaily = {
      text = ''
        cd ${dav_root}
        if ls ./* &> /dev/null; then
          restic backup --tag=webdav --skip-if-unchanged=true -- ./android-backup/
        fi
      '';
    };
    forget = {
      text = ''
        # Primarily stores seedvault-files, which can get rather big :|
        # They are not plain text, but encrypted, so no good incremental sync
        # => only keep one up-to-date backup.
        restic forget --tag=webdav --group-by=tag --keep-last=1
      '';
    };
  };
}
