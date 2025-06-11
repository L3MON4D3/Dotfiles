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

  services.caddy.extraConfig = ''
    http://mympd, http://mympd.internal, http://mympd.${machine} {
      reverse_proxy http://${machine_lan_address}:${port}
    }
  '';
}
