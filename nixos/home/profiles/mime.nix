{ config, lib, pkgs, machine, data, ... }:

let 
  qutebrowser = ["org.qutebrowser.qutebrowser.desktop"];
  zathura = ["org.pwmt.zathura-pdf-mupdf.desktop"];
  thunderbird = ["userapp-Thunderbird-D15E22.desktop"];

  associations = {
    # "inode/directory" = [ "foot.desktop" ];
    "text/html" = qutebrowser;

    "x-scheme-handler/http" = qutebrowser;
    "x-scheme-handler/https" = qutebrowser;
    "x-scheme-handler/about" = qutebrowser;
    "x-scheme-handler/unknown" = qutebrowser;
    "x-scheme-handler/ftp" = qutebrowser;
    "x-scheme-handler/chrome" = qutebrowser;

    "application/x-extension-htm" = qutebrowser;
    "application/x-extension-html" = qutebrowser;
    "application/x-extension-shtml" = qutebrowser;
    "application/xhtml+xml" = qutebrowser;
    "application/x-extension-xhtml" = qutebrowser;
    "application/x-extension-xht" = qutebrowser;

    "application/pdf" = zathura;

    "x-scheme-handler/mailto" = thunderbird;
    "message/rfc822" = thunderbird;
    "x-scheme-handler/mid" = thunderbird;
  };
in {
  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    associations.added = associations;
    defaultApplications = associations;
  };
}
