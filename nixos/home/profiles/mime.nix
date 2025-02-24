{ config, lib, pkgs, machine, data, ... }:

let 
  browser = ["qutebrowser.desktop"];
  associations = {
    # "inode/directory" = [ "foot.desktop" ];
    "text/html" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/chrome" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/unknown" = browser;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/xhtml+xml" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-extension-xht" = browser;
    "x-scheme-handler/mailto" = ["userapp-Thunderbird-D15E22.desktop"];
    "message/rfc822" = ["userapp-Thunderbird-D15E22.desktop"];
    "x-scheme-handler/mid" = ["userapp-Thunderbird-D15E22.desktop"];
  };
in {
  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    associations.added = associations;
    defaultApplications = associations;
  };

}
