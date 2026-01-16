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
        connect-timeout = 5;
        substituters = lib.mkOrder data.ordering.peercache-substituters (lib.attrsets.foldlAttrs (acc: name: os:
          if os.config.l3mon.peercache.push && name != machine then
            acc ++ ["https://cache.${name}.internal"]
          else acc) [] self.outputs.nixosConfigurations);
        trusted-public-keys = lib.attrsets.foldlAttrs (acc: name: os:
          if os.config.l3mon.peercache.push && name != machine then
            # we only use this key for signing.
            acc ++ ["cache.${name}.internal:dmRV8DJW4a9BBGtzXO2bYAfZAU5l7utBg4n4fTkfSRE="]
          else acc) [] self.outputs.nixosConfigurations;
      };
    })
    (mkIf cfg.push {

      l3mon.secgen.secrets.peercache = rec {
        backup_files = [];
        gen = pkgs.writeShellApplication {
          name = "gen";
          text =
          # bash 
          ''
            tmpkey=$(mktemp)
            tmppubkey=$(mktemp)

            nix-store --generate-binary-cache-key "" "$tmpkey" "$tmppubkey"

            KEY=$(cat "$tmpkey")
            PUBKEY=$(cat "$tmppubkey")

            echo "Update 'peercache-raw' to $PUBKEY in data/pubkeys.nix"

            rm "$tmpkey"
            rm "$tmppubkey"
          '' +
            lib.attrsets.foldlAttrs (acc: name: _: acc + ''
              echo -n "cache.${name}.internal$KEY" > /var/secrets/nix-serve-key-${name}
            '') "" self.outputs.nixosConfigurations;
        };
      } // lib.attrsets.concatMapAttrs (name: os: {"key-${name}" = "${config.l3mon.secgen.secret_dir}/nix-serve-key-${name}";}) self.outputs.nixosConfigurations;

      services.harmonia = {
        enable = true;
        signKeyPaths = [config.l3mon.secgen.secrets.peercache."key-${machine}"];
        settings = {
          bind = "127.0.0.1:${toString data.ports.harmonia}";
        };
      };


      l3mon.services.defs.cache = {
        cfg = data.ports.harmonia;
        network = false;
      };
    })
  ];
}
