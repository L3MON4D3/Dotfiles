{ config, lib, pkgs, pkgs-unstable, machine, data, l3lib, ... }:

{
  services.pinchflat = {
    enable = true;
    package = pkgs-unstable.pinchflat;
    port = data.ports.pinchflat;
    mediaDir = "/srv/media/video/youtube";
    selfhosted = true;
    secretsFile = l3lib.secret "pinchflat_env";
  };

  users.users.pinchflat = {
    isSystemUser = true;
    uid = data.ids.pinchflat;
    extraGroups = ["media"];
    group = "pinchflat";
  };
  users.groups.pinchflat.gid = data.ids.pinchflat;

  systemd.services.pinchflat.serviceConfig = {
    User = "pinchflat";
    Group = "pinchflat";
    DynamicUser = lib.mkForce false;
  };

  services.caddy.extraConfig = ''
    http://pinchflat, http://pinchflat.internal, http://pinchflat.${machine} {
      reverse_proxy http://127.0.0.1:${toString data.ports.pinchflat}
    }
  '';
}
