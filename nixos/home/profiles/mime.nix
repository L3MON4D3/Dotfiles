{ config, lib, pkgs, machine, data, ... }:

let 
  qutebrowser = ["org.qutebrowser.qutebrowser.desktop"];
  firefox = ["firefox.desktop"];
  zathura = ["org.pwmt.zathura-pdf-mupdf.desktop"];
  thunderbird = ["userapp-Thunderbird-D15E22.desktop"];

  associations = {
    # "inode/directory" = [ "foot.desktop" ];
    "text/html" = firefox;

    "x-scheme-handler/http" = firefox;
    "x-scheme-handler/https" = firefox;
    "x-scheme-handler/about" = firefox;
    "x-scheme-handler/unknown" = firefox;
    "x-scheme-handler/ftp" = firefox;
    "x-scheme-handler/chrome" = firefox;

    "application/x-extension-htm" = firefox;
    "application/x-extension-html" = firefox;
    "application/x-extension-shtml" = firefox;
    "application/xhtml+xml" = firefox;
    "application/x-extension-xhtml" = firefox;
    "application/x-extension-xht" = firefox;

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
