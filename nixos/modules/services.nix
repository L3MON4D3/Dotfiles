{ config, lib, pkgs, machine, data, ... }:

with lib;
let
  to_network_hostname = name: "https://${name}.internal";
  to_machine_hostname = name: "https://${name}.${machine}.internal";
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
              type = either str port;
              default = null;
              description = lib.mdDoc "Set string to insert into host-clause, or number/port to reverse proxy it on 127.0.0.1.";
            };
            machine = mkOption { example = true; type = bool; default = true; };
            network = mkOption { example = true; type = bool; default = true; };
            network_hostname = mkOption {
              example = "https://jellyfin.internal";
              type = str;
              default = to_network_hostname name;
            };
            machine_hostname = mkOption {
              example = "https://jellyfin.indigo.internal";
              type = str;
              default = to_machine_hostname name;
            };
          };
        } )];
      });
      description = lib.mdDoc "Definitions for services.";
      default = {};
    };
  };
  config = let
    cfg = config.l3mon.services;
    map_service = name: def: let
      network_hostname = if def.network then to_network_hostname name else "";
      machine_hostname = if def.machine then to_machine_hostname name else "";
      config = if isString def.cfg then def.cfg else "reverse_proxy http://127.0.0.1:${toString def.cfg}";
    in {
      caddy_conf = ''
        ${toString [network_hostname machine_hostname]} {
          tls internal
          ${config}
        }
      '';
    };
  # in mkIf cfg.enable (map_service "git" cfg.defs.git);
  in mkIf cfg.enable {
    services.caddy.extraConfig = mkMerge (attrsets.foldlAttrs (acc: name: def: acc ++ [(map_service name def).caddy_conf]) [ ] cfg.defs);
    l3mon.networks = let
      peerconf = {
        machine_services = attrsets.foldlAttrs (acc: name: def: acc ++ (if def.machine then [name] else [])) [ ] cfg.defs;
        network_services = attrsets.foldlAttrs (acc: name: def: acc ++ (if def.network then [name] else [])) [ ] cfg.defs;
      };
    in {
      physical.home.peers.${machine} = peerconf;
      virtual.home.peers.${machine} = peerconf;
    };

    services.caddy = {
      enable = true;
      enableReload = true;
      globalConfig = let
        caddy_ca_root = config.l3mon.secgen.secrets.caddy_ca_root;
      in ''
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
