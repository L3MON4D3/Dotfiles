{ config, lib, pkgs, machine, data, ... }:

{
  xdg.configFile."jellyfin-mpv-shim/cred.json".text = ''
[{"address": "http://jellyfin.internal:80", "Name": "indigo", "Id": "19115077000e43dca1172812a4f96c59", "Version": "10.10.7", "DateLastAccessed": "2025-05-25T17:26:04Z", "UserId":"db65cdf9d37b4d7cb0fdfe39058c5657", "AccessToken": "c04fbd73e5514e698fa95b30fc1ded11", "Users": [{"Id": "db65cdf9d37b4d7cb0fdfe39058c5657", "IsSignedInOffline": true}], "uuid": "a364a772-5157-4c40-9b9f-642e78724c94", "username": "simon", "connected": true}]
'';
}
