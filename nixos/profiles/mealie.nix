{ config, lib, pkgs, pkgs-unstable, machine, data, ... }:

{
  services.mealie = {
    enable = true;
    package = pkgs.mealie.overrideAttrs (old: rec {
      version = "3.1.2";
      src = pkgs.fetchFromGitHub {
        owner = "mealie-recipes";
        repo = "mealie";
        tag = "v3.1.2";
        hash = "sha256-8ZLXXA4NKR7GaCdgk8XDMjAssQsKP1wZpEZPYWpglwk=";
        # hash = "sha256-txkHCQ/xTakPXXFki161jNOKwAH9p9z1hCNEEkbqQtM=";
      };
      patches = [];
    });
    port = data.ports.mealie;
  };

  users.users.mealie = {
    isSystemUser = true;
    uid = data.ids.mealie;
    group = "mealie";
  };
  users.groups.mealie.gid = data.ids.mealie;
  
  systemd.services.mealie.serviceConfig = {
    User = "mealie";
    Group = "mealie";
    DynamicUser = lib.mkForce false;
  };

  services.caddy.extraConfig = ''
    http://mealie, http://mealie.internal, http://mealie.${machine} {
      reverse_proxy http://127.0.0.1:${toString data.ports.mealie}
    }
  '';

  l3mon.restic.extraGroups = [ "mealie" ];
  l3mon.restic.specs.mealie = {
    backupStopResumeServices = ["mealie.service"];
    backupDaily = {
      text = ''
        cd /var/lib/mealie/
        restic backup --tag=mealie --skip-if-unchanged=true -- ./recipes ./templates ./users
      '';
    };
    forget = {
      text = ''
        restic forget --tag=mealie --group-by=tag --keep-daily=7 --keep-monthly=12
      '';
    };
  };
}
