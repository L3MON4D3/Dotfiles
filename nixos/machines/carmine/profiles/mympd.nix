{ config, lib, pkgs, machine, data, ... }:

let
  machine_lan_address = data.network.lan.peers.${machine}.address;
  port = data.ports.mympd;
in {
  services.mympd = {
    enable = true;
    settings = {
      http_port = lib.strings.toInt port;
    };
  };

  l3mon.services.defs.mympd.cfg = port;
}
