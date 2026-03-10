{ config, lib, pkgs, machine, data, self, ... }:

let
  zotprime-client = "${(pkgs.writeShellApplication {
    name = "zotero-zotprime";
    text = ''
      ${self.nixosConfigurations.indigo.config.lib.l3mon.zotprime-client}/bin/zotero "$@"
    '';
  })}/bin/zotero-zotprime";
  common_prefs = ''
    user_pref("extensions.zotero.useDataDir", true);
    user_pref("extensions.zotero.sync.storage.downloadMode.personal", "on-demand");
    user_pref("extensions.zotero.sync.storage.downloadMode.groups", "on-demand");
    user_pref("extensions.zotero.firstRun.skipFirefoxProfileAccessCheck", true);
  '';
  profilepath_prefix = "/home/simon/.zotero";
  datapath_prefix = "${config.xdg.dataHome}/zotero";
  personal = {
    profile = "${profilepath_prefix}/personal";
    data = "${datapath_prefix}/personal";
  };
  unibonn = {
    profile = "${profilepath_prefix}/unibonn";
    data = "${datapath_prefix}/unibonn";
  };
in {
  wayland.windowManager.sway.extraConfig = ''
    mode "apps" {
      bindsym z mode "zotero-profiles"
    }
    mode "zotero-profiles" {
      bindsym p exec ${zotprime-client} --profile ${personal.profile}
      bindsym u exec ${zotprime-client} --profile ${unibonn.profile}

      bindsym Return mode "default"
      bindsym Escape mode "default"
    }
  '';

  home.activation.zotprime-client = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ${unibonn.profile} ${unibonn.data}
    mkdir -p ${personal.profile} ${personal.data}
  '';

  home.file.".zotero/zotero/profiles.ini".text = ''
    [Profile1]
    Name=unibonn
    IsRelative=0
    Path=${unibonn.profile}

    [Profile0]
    Name=personal
    IsRelative=0
    Path=${personal.profile}
    Default=1

    [General]
    StartWithLastProfile=1
    Version=2
  '';

  home.file.".zotero/unibonn/user.js".text = ''
    user_pref("extensions.zotero.sync.server.username", "simon-unibonn");
    user_pref("extensions.zotero.dataDir", "${unibonn.data}");

  '' + common_prefs;

  home.file.".zotero/personal/user.js".text = ''
    user_pref("extensions.zotero.sync.server.username", "admin");
    user_pref("extensions.zotero.dataDir", "${personal.data}");
  '' + common_prefs;
}
