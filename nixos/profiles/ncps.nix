{ self, config, lib, pkgs, machine, data, ... }:

{
  services.ncps = {
    enable = true;
    cache = {
      hostName = "ncps.internal";
      allowPutVerb = true;
      allowDeleteVerb = true;
      secretKeyPath = config.l3mon.secgen.secrets.ncps.key;
    };
    server.addr = "127.0.0.1:${toString data.ports.ncps}";
    upstream = {
      # if possible, pull from local caches.
      caches = (lib.attrsets.foldlAttrs (acc: name: os:
          if os.config.l3mon.peercache.push && {"carmine"=null; "indigo"=null;} ? ${name} then
            acc ++ ["http://cache.${name}.internal"]
          else acc) [] self.outputs.nixosConfigurations)
      ++ [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      publicKeys = with data.pubkeys; [
        cachix-community
        nixos-org
        peercache-carmine
        peercache-indigo
      ];
    };
  };

  systemd.services.ncps = {
    after = [ "blocky_lan.service" ];
    serviceConfig.RestartSec = "30s";
  };

  services.caddy.extraConfig = ''
    http://ncps, http://ncps.internal, http://ncps.${machine} {
      reverse_proxy http://127.0.0.1:${toString data.ports.ncps}
    }
  '';

  l3mon.secgen.secrets.ncps = rec {
    key = "${config.l3mon.secgen.secret_dir}/nix-cache-ncps";
    backup_files = [ key ];
    gen = pkgs.writeShellApplication {
      name = "gen";
      text =
      # bash 
      ''
        tmppubkey=$(mktemp)
        nix-store --generate-binary-cache-key "ncps.internal" "${key}" "$tmppubkey"

        PUBKEY=$(cat "$tmppubkey")
        echo "Update 'ncps' to \"$PUBKEY\" in data/pubkeys.nix"

        rm "$tmppubkey"
      '';
    };
  };
}
