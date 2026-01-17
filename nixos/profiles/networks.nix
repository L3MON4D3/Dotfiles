{ config, l3lib, lib, pkgs, machine, data, ... }:

{
  l3mon.networks = rec {
    physical.home = rec {
      inherit (data.network.home) address_range ssid;
      dns_peer_id = "indigo";
      gateway_peer_id = "fritzbox";
      peers = l3lib.deepMerge data.network.home.peers rec {
        merigold.machine_services = [
          "nix-cache"
          "nix-tarballs"
          "pds"
        ];
        merigold-test.machine_services = merigold.machine_services;
        # carmine.machine_services = [ "cache" ];
      };
    };
    virtual = {
      home = rec {
        inherit (data.network.wg_home) address_range;
        keepalive = true;
        host_id = "indigo";
        peers = l3lib.deepMerge data.network.wg_home.peers {
          teal = { route_all = true; };
          remarkable = { route_all = true; };
          xperia = { route_all = true; };
          carmine = { route_all = true; };

          indigo = { route_all = false; };
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
        host_id = "indigo";
        peers = l3lib.deepMerge data.network.wg_rec_de.peers {
          carmine = { route_all = true; local = config.lib.l3mon.networks.physical.home.peers.carmine_mullvad_de; };
          cobalt = { route_all = true; };
        };
      };
    };
    remote = {
      mullvad_de = {
        peer_machine = "indigo";
        local = config.lib.l3mon.networks.physical.home.peers.indigo_mullvad_de;
      };
    };
  };
}
