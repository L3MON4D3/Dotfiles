{ config, lib, l3lib, pkgs, machine, data, self, ... }:

with lib;
{
  options = {
    l3mon.peercache = {
      pull = mkEnableOption "Pull from other caches.";
      push = mkEnableOption "Push to other caches.";
    };
  };
  config = let
    cfg = config.l3mon.peercache;
    machine_lan_address = data.network.lan.peers.${machine}.address;
  in mkMerge [
    (mkIf cfg.pull {
      # check configs for other machines, only put those that have push enabled.
      nix.settings = {
        substituters = lib.attrsets.foldlAttrs (acc: name: os:
          if os.config.l3mon.peercache.push then
            acc ++ ["http://cache.${name}.internal"]
          else acc) [] self.outputs.nixosConfigurations;
        trusted-public-keys = lib.attrsets.foldlAttrs (acc: name: os:
          if os.config.l3mon.peercache.push then
            # we only use this key for signing.
            acc ++ ["cache.${name}.internal:CA2Hg9Xq3wNRTOU/Pombi0CLc2aemwlyPw/o34zDrKA="]
          else acc) [] self.outputs.nixosConfigurations;
      };
    })
    (mkIf cfg.push {
      services.nix-serve = {
        enable = true;
        secretKeyFile = l3lib.secret "cache-priv-key.pem";
        port = data.ports.nix-serve;
      };

      services.caddy.extraConfig = ''
        http://cache.${machine}.internal {
          reverse_proxy http://${machine_lan_address}:${toString data.ports.nix-serve}
        }
      '';
    })
  ];
}
