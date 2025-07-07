{ config, lib, pkgs, machine, data, ... }:

let
  qbt-manager = pkgs.writers.writePython3Bin "qb_manager.py" {
    libraries = [ pkgs.python3.pkgs.qbittorrent-api ];
  } ''
    import qbittorrentapi
    import sys
    from subprocess import Popen


    def torrent_notification_string(torr):
        # 34 is limit from mako.
        name = torr['name']
        if len(name) > 34:
            name = name[0:31] + '...'

        return (
            # '<span weight="bold">' +
            name +
            # '</span>' +
            '\n' +
            '{:5.1f}'.format(float(torr['progress']*100))+'%' + '   ' +
            '{:6.1f}'.format(float(torr['dlspeed'])/1024) + ' ↓    ' +
            '{:6.1f}'.format(float(torr['upspeed'])/1024) + ' ↑    ' + '\n')


    client = qbittorrentapi.Client(host="qbittorrent.internal:80")
    if sys.argv[1] == "addMagnet":
        client.torrents_add(urls=sys.argv[2])
    elif sys.argv[1] == "addFile":
        client.torrents_add(torrent_files=sys.argv[2])
    elif sys.argv[1] == "status":
        Popen(['${pkgs.libnotify}/bin/notify-send', '-c', 'torr', 'Torrents', "".join(  # noqa: E501. The path is too long.
            map(torrent_notification_string,
                # sort torrents by date, most recent first.
                filter(
                    lambda info: info["category"] != "hide",
                    sorted(
                      client.torrents_info(),
                      key=lambda item: -item["added_on"]))))])
  '';
in {
  services.mako = {
    enable = true;
    settings = {
      font="monospace 10";

      background-color="#${data.gruvbox.bg0_h}";
      text-color="#${data.gruvbox.fg}";

      border-size=1;
      border-color="#${data.gruvbox.fg}";
      border-radius=1;

      markup=1;
      margin=5;

      height=2000;
      "category=\"torr\"" = {
        format="%b";
      };
    };
  };
  wayland.windowManager.sway.extraConfig = ''
    mode "torrent" {
      bindsym s exec 'makoctl dismiss -a && ${qbt-manager}/bin/qb_manager.py status'
      bindsym c exec makoctl dismiss -a
      bindsym Return mode "default"
      bindsym Escape mode "default"
    }
    bindsym $mod+t mode "torrent"
  '';

  home.packages = with pkgs; [
    (pkgs.writeTextFile {
      name = "qb-magnet-add";
      text = ''
        [Desktop Entry]
        Categories=Network;FileTransfer;P2P;Qt;
        Exec=${qbt-manager}/bin/qb_manager.py addMagnet %u
        GenericName=Add torrent
        Comment=Download and share files over BitTorrent
        Icon=qbittorrent
        MimeType=x-scheme-handler/magnet;
        Name=qBittorrent-magnet
        Terminal=false
        Type=Application
        StartupNotify=false
        Keywords=bittorrent;torrent;magnet;download;p2p;
      '';
      destination = "/share/applications/qb-magnet-add.desktop";
    })
    (pkgs.writeTextFile {
      name = "qb-torrent-add";
      text = ''
        [Desktop Entry]
        Categories=Network;FileTransfer;P2P;Qt;
        Exec=${qbt-manager}/bin/qb_manager.py addFile %f
        GenericName=Add torrent
        Comment=Download and share files over BitTorrent
        Icon=qbittorrent
        MimeType=application/x-bittorrent
        Name=qBittorrent-torrentfile
        Terminal=false
        Type=Application
        StartupNotify=false
        Keywords=bittorrent;torrent;magnet;download;p2p;
      '';
      destination = "/share/applications/qb-torrent-add.desktop";
    })
  ];
  xdg.mimeApps.defaultApplications = {
    "application/x-bittorrent" = ["qb-torrent-add.desktop"];
    "x-scheme-handler/magnet" = ["qb-magnet-add.desktop"];
  };
}
