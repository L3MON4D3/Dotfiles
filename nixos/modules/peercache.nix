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
        # low timeout in case one of my machines is offline.
        connect-timeout = 1;
        substituters = lib.mkBefore (lib.attrsets.foldlAttrs (acc: name: os:
          if os.config.l3mon.peercache.push && name != machine then
            acc ++ ["http://cache.${name}.internal"]
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
        backup_relfiles = [];
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

            echo "Update pubkey to $PUBKEY in peercache.nix"

            rm "$tmpkey"
            rm "$tmppubkey"
          '' +
            lib.attrsets.foldlAttrs (acc: name: _: acc + ''
              echo -n "cache.${name}.internal$KEY" > /var/secrets/nix-serve-key-${name}
            '') "" self.outputs.nixosConfigurations;
        };
      } // lib.attrsets.concatMapAttrs (name: os: {"key-${name}" = "/var/secrets/nix-serve-key-${name}";}) self.outputs.nixosConfigurations;

      services.nix-serve = {
        enable = true;
        secretKeyFile = config.l3mon.secgen.secrets.peercache."key-${machine}";
        port = data.ports.nix-serve;
      };

      services.caddy = {
        enable = true;
        extraConfig = ''
          http://cache.${machine}.internal {
            reverse_proxy http://${machine_lan_address}:${toString data.ports.nix-serve}
          }
        '';
      };
    })
  ];
}
