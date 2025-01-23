{ config, lib, pkgs, machine, data, ... }:

with lib;
{
  xdg.stateFile."zotero/user.js".text = ''
    user_pref("extensions.zotero.useDataDir", true);
    # TOOD: change this file.
    user_pref("extensions.zotero.dataDir", "/mnt/misc/zotero/data");

    user_pref("extensions.zotero.findPDFs.resolvers", "[     {         \"name\":\"Sci-Hub\",         \"method\":\"GET\",         \"url\":\"https://sci-hub.se/{doi}\",         \"mode\":\"html\",         \"selector\":\"#pdf\",         \"attribute\":\"src\",         \"automatic\":true     },     {         \"name\":\"annas-archive\",         \"method\":\"GET\",         \"url\":\"https://annas-archive.org/scidb/{doi}\",         \"mode\":\"html\",         \"selector\":\"li>a\",         \"index\":3,         \"attribute\":\"href\",         \"automatic\":true     } ]");
    user_pref("extensions.zotero.openURL.resolver", "https://annas-archive.org/scidb/?");

    user_pref("extensions.zotero.firstRun.skipFirefoxProfileAccessCheck", true);

  '';

  home.packages = with pkgs; [
    zotero
  ];
}
