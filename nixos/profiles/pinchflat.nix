{ config, lib, pkgs, pkgs-unstable, machine, data, l3lib, ... }:

let
  yt_dlp_config = pkgs.writeText "yt-dlp-conf" ''
    # youtube seems to heavily rate-limit auto-translated subtitle downloads =>
    # ignore errors and just download the subtitles youtube doesn't 429.
    # --extractor-args 'youtube:skip=translated_subs'
    -i
    # generated via procedure described [here](https://github.com/yt-dlp/yt-dlp/wiki/Extractors#exporting-youtube-cookies)
    --cookies ${l3lib.secret "youtube-cookies.txt"}
  '';
in {
  services.pinchflat = {
    enable = true;
    package = pkgs-unstable.pinchflat;
    port = data.ports.pinchflat;
    mediaDir = "/srv/media/video/youtube";
    selfhosted = true;
    secretsFile = l3lib.secret "pinchflat_env";
  };

  system.activationScripts.pinchflat = {
    text = ''
      install -D -o pinchflat -g pinchflat ${yt_dlp_config} "/var/lib/pinchflat/extras/yt-dlp-configs/base-config.txt"
    '';
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
