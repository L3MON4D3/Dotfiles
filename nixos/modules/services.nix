{ config, lib, pkgs, machine, data, ... }:

with lib;
let
  to_network_domain = name: "${name}.internal";
  to_machine_domain = name: "${name}.${machine}.internal";
  to_network_url = name: "https://${name}.internal";
  to_machine_url = name: "https://${name}.${machine}.internal";
in {
  options.l3mon.services = {
    enable = mkEnableOption (lib.mdDoc "Enable reverse proxy for services.");
    defs = mkOption {
      type = with types; attrsOf (submoduleWith {
        modules = [( { name, ... }: {
          options = {
            cfg = mkOption {
              example = ''
                file_server
              '';
              type = nullOr (either str port);
              default = null;
              description = lib.mdDoc "Set string to insert into host-clause, or number/port to reverse proxy it on 127.0.0.1.";
            };
            match_machine = mkOption { example = true; type = bool; default = true; };
            match_network = mkOption { example = true; type = bool; default = true; };
            network_domain = mkOption {
              example = "jellyfin.internal";
              type = str;
              default = to_network_domain name;
            };
            machine_domain = mkOption {
              example = "jellyfin.indigo.internal";
              type = str;
              default = to_machine_domain name;
            };
            extraHostnames = mkOption {
              example = "somehost.tld";
              type = listOf str;
              default = [];
            };
            networks = mkOption {
              type = listOf attrs;
              default = with config.lib.l3mon.networks; [ physical.home virtual.home ];
            };
          };
        } )];
      });
      description = lib.mdDoc "Definitions for services.";
      default = {};
    };
  };
  # TODO: map every used TLD to an entry in the generated cert?
  config = let
    cfg = config.l3mon.services;
    service_caddy_extraConfig = name: def: let
      network_domain = if def.match_network then to_network_domain name else "";
      machine_domain = if def.match_machine then to_machine_domain name else "";
      config = if def.cfg != null then
          if isString def.cfg then def.cfg else "reverse_proxy http://127.0.0.1:${toString def.cfg}"
        else
          null;
      allowed_ip_ranges = toString (map (network: network.address_range) def.networks);
    in if config != null then
      [''
        ${toString ([ network_domain machine_domain ] ++ def.extraHostnames)} {
          @not_allowed not remote_ip ${allowed_ip_ranges}
          abort @not_allowed
          log
          tls internal
          ${config}
        }
      '']
    else
      [ ];
  in mkIf cfg.enable {
    services.caddy.extraConfig = mkMerge (attrsets.foldlAttrs (acc: name: def: acc ++ (service_caddy_extraConfig name def)) [ ] cfg.defs);
    l3mon.networks = let
      peerconf = {
        machine_services = attrsets.foldlAttrs (acc: name: def: acc ++ (if def.match_machine then [name] else [])) [ ] cfg.defs;
        network_services = attrsets.foldlAttrs (acc: name: def: acc ++ (if def.match_network then [name] else [])) [ ] cfg.defs;
      };
    in {
      physical.home.peers.${machine} = peerconf;
      virtual.home.peers.${machine} = peerconf;
      virtual.work.peers.${machine} = peerconf;
    };

    services.caddy = {
      enable = true;
      enableReload = true;
      globalConfig = let
        caddy_ca_root = config.l3mon.secgen.secrets.caddy_ca_root;
      in ''
        # cert install handled by nixos.
        skip_install_trust
        pki {
          ca local {
            root {
              format pem_file
              cert ${caddy_ca_root.cert}
              key ${caddy_ca_root.key}
            }
          }
        }
      '';
    };
    networking.firewall.allowedTCPPorts = with data.ports; [ http https ];
  };
}
