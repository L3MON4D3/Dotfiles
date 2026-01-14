{ config, l3lib, lib, pkgs, machine, data, ... }:

{
  l3mon.networks = {
    physical.home = rec {
      inherit (data.network.home) address_range ssid;
      dns_peer = peers.indigo;
      gateway_peer = peers.fritzbox;
      peers = l3lib.deepMerge data.network.home.peers rec {
        indigo.network_services = [
          "mysql"
          "jackett"
          "radarr"
          "sonarr"
          "qbittorrent"
          "jellyfin"
          "git"
          "immich"
          "paperless"
          "rmfakecloud"
          "zotero"
          "radicale"
          "webdav"
          "restic"
          "cache.indigo"
          "readeck"
          "mealie"
          "pinchflat"
          "kiwix"
          "zimit"
          "linkding"
          "ddns-updater"
          "zotero-serve"
          "ncps"
        ];
        merigold.machine_services = [
          "nix-cache"
          "nix-tarballs"
          "pds"
        ];
        merigold-test.machine_services = merigold.machine_services;
        carmine.machine_services = [ "cache" ];
      };
    };

    virtual = {
      home = rec {
        inherit (data.network.wg_home) address_range;
        keepalive = true;
        host = peers.indigo;
        peers = l3lib.deepMerge data.network.wg_home.peers {
          teal = { route_all = true; };
          remarkable = { route_all = true; };
          xperia = { route_all = true; };
          carmine = { route_all = true; };

          # indigo = { route_all = false; };
          canary = { route_all = false; };
          cobalt = { route_all = false; };
          chromecast = { route_all = false; };
          kim-laptop = { route_all = false; };
          kim-desktop = { route_all = false; };
        };
      }; 
      rec_de = rec {
        inherit (data.network.wg_rec_de) address_range;
        keepalive = true;
        host = peers.indigo;
        peers = l3lib.deepMerge data.network.wg_rec_de.peers {
          carmine = { route_all = true; };
          cobalt = { route_all = true; };
        };
      };
    };
    remote = {
      mullvad_de = {
        peer_machine = "indigo";
        local = config.lib.l3mon.networks.physical.home.peers.indigo;
      };
    };
  };
}
