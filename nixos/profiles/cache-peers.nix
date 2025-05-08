{ config, l3lib, lib, pkgs, machine, data, ... }:

let 
  machine_lan_address = data.network.lan.peers.${machine}.address;
in {
  services.nix-serve = {
    enable = true;
    # unclean! should make this independent of hosting on indigo.
    secretKeyFile = l3lib.secret "cache-priv-key.pem";
  };

  services.caddy.extraConfig = ''
    http://cache.${machine}.internal {
      reverse_proxy http://${machine_lan_address}:${builtins.toString config.services.nix-serve.port}
    }
  '';

  # set this up so this config is valid on all machines.
  nix.settings = {
    substituters = [
      "http://cache.indigo.internal"
      "http://cache.carmine.internal"
    ];
    trusted-public-keys = [
      # all use the same public key!
      "cache.indigo.internal:CA2Hg9Xq3wNRTOU/Pombi0CLc2aemwlyPw/o34zDrKA="
      "cache.carmine.internal:CA2Hg9Xq3wNRTOU/Pombi0CLc2aemwlyPw/o34zDrKA="
    ];
  };

}
