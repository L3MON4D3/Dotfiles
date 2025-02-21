{ config, l3lib, lib, pkgs, machine, data, ... }:

let 
  machine_lan_address = data.network.lan.peers.${machine}.address;
in {
  services.nix-serve = {
    enable = true;
    # unclean! should make this independent of hosting on indigo.
    secretKeyFile = l3lib.secret "indigo-cache-priv-key.pem";
  };

  services.caddy.extraConfig = ''
    http://cache.indigo.internal {
      reverse_proxy http://${machine_lan_address}:${builtins.toString config.services.nix-serve.port}
    }
  '';
}
