{ config, lib, pkgs, machine, data, ... }:

{
  # maybe have to update this?
  xdg.configFile."jellyfin-mpv-shim/cred.json".text = ''
    [{"address": "http://jellyfin.internal:8096", "Name": "indigo", "Id": "19115077000e43dca1172812a4f96c59", "Version": "10.11.5", "DateLastAccessed": "2026-01-17T01:25:03Z", "UserId": "db65cdf9d37b4d7cb0fdfe39058c5657", "AccessToken": "173705f4701a433787bb69db0f938be1", "Users": [{"Id": "db65cdf9d37b4d7cb0fdfe39058c5657", "IsSignedInOffline": true}], "uuid": "ec46c23f-29ad-43a8-8fd1-12f26ec59351", "username": "simon", "connected": true}]
  '';
}
