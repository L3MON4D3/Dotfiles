{ config, lib, pkgs, machine, data, ... }:

{
  # maybe have to update this?
  xdg.configFile."jellyfin-mpv-shim/cred.json".text = ''
    [{"address": "http://jellyfin.internal", "Name": "indigo", "Id": "19115077000e43dca1172812a4f96c59", "Version": "10.10.7", "DateLastAccessed": "2025-05-31T23:00:28Z", "UserId": "db65cdf9d37b4d7cb0fdfe39058c5657", "AccessToken": "6f98461806084700b59e58475c2cd698", "Users": [{"Id": "db65cdf9d37b4d7cb0fdfe39058c5657", "IsSignedInOffline": true}], "uuid": "ef4258af-90d9-4f29-9219-f604c9ab6ba7", "username": "simon", "connected": true}]
  '';
}
