{ config, lib, pkgs, machine, data, ... }:

with lib;
let
  physical_machine_spec_t = with types; submodule {
    options = {
      address = mkOption { type = nullOr str; default = null; };

      mac = mkOption { example = "aa:aa:aa:aa:aa:aa"; type = nullOr str; default = null; };
      interface = mkOption { example = "enp34s0"; type = nullOr str; default = null; };

      phys_mac = mkOption { example = "aa:aa:aa:aa:aa:aa"; type = nullOr str; default = null; };
      phys_interface = mkOption { example = "enp34s0"; type = nullOr str; default = null; };

      # register as '<service>.<machine>.internal'.
      machine_services = mkOption { type = listOf str; default = []; };
      # register as '<service>.internal'.
      network_services = mkOption { type = listOf str; default = []; };
    };
  };
  virtual_machine_spec_t = with types; submodule {
    options = {
      address = mkOption { type = str; };

      # persistent endpoint for machine.
      endpoint = mkOption { example = "wireguard.l3mon4.de:1234"; type = nullOr str; default = null; };
      route_all = mkOption { type = bool; default = false; };

      # register as '<service>.<machine>.internal'.
      machine_services = mkOption { type = listOf str; default = []; };
      # register as '<service>.internal'.
      network_services = mkOption { type = listOf str; default = []; };
    };
  };
  physical_network_spec_t = with types; submodule {
    options = {
      address_range = mkOption { example = "192.168.178.0/24"; type = str; };
      dns_peer = mkOption { type = physical_machine_spec_t; };
      gateway_peer = mkOption { type = physical_machine_spec_t; };
      ssid = mkOption { example = "FRITZ!Box XXX"; type = str; };
      
      peers = mkOption { type = attrsOf physical_machine_spec_t; };
    };
  };
  virtual_network_spec_t = with types; submodule {
    options = {
      address_range = mkOption { example = "192.168.178.0/24"; type = str; };
      host = mkOption { type = virtual_machine_spec_t; };
      keepalive = mkOption { type = bool; default = false; };

      peers = mkOption { type = attrsOf virtual_machine_spec_t; };
    };
  };
  remote_network_spec_t = with types; submodule {
    options = {
      peer_machine = mkOption { type = str; };
      local = mkOption { type = attrs; };
    };
  };
in {
  options.l3mon.networks = {
    physical = with types; mkOption {
      type = attrsOf physical_network_spec_t;
      default = {};
    };
    virtual = with types; mkOption {
      type = attrsOf virtual_network_spec_t;
      default = {};
    };
    remote = with types; mkOption {
      type = attrsOf remote_network_spec_t;
      default = {};
    };
  };

  config = let
    cfg = config.l3mon.networks;
    map_phys_peer = name: spec: spec // {
      machine_id = name;
    };
    map_phys_network = spec: {
      address_range = spec.address_range;
      # "192.168.178.21/xx" -> /xx
      subnet_mask = "/" + (elemAt (split "/" spec.address_range) 2);
      dns = spec.dns_peer.address;
      gateway_ip = spec.gateway_peer.address;
      gateway_mac = spec.gateway_peer.mac;
      ssid = spec.ssid;

      peers = mapAttrs map_phys_peer spec.peers;
    };

    map_virt_peer = net_prefix: name: spec: spec // (let
      peer_secgen = config.l3mon.secgen.secrets.${config.lib.l3mon.secgen.wireguardSpecKey net_prefix name};
    in {
      machine_id = name;
      privkey_file = peer_secgen.key;
      pubkey = import (./.. + "${peer_secgen.nix_pubkey_repo}");
    });
    map_virt_network = name: spec: let
      host_mapped = attrsets.foldlAttrs (acc: k: v: if v == spec.host then map_virt_peer name k v else acc) null spec.peers;
    in {
      name = name;
      address_range = spec.address_range;
      # "192.168.178.21/xx" -> /xx
      subnet_mask = "/" + (elemAt (split "/" spec.address_range) 2);

      host = host_mapped;
      dns = spec.host.address;

      keepalive = spec.keepalive;

      peers = mapAttrs (map_virt_peer name) spec.peers;
    };
    map_remote_network = name: spec: (let
      secgen = config.l3mon.secgen.secrets.${config.lib.l3mon.secgen.wireguardSpecKeySingle name};
      conf = import (./.. + "${secgen.nix_data_repo}");
    in {
      name = name;

      host = {
        endpoint = conf.remote_endpoint;
        pubkey = conf.remote_pubkey;
      };
      dns = conf.dns;

      peers = {
        ${spec.peer_machine} = {
          address = conf.address;
          pubkey = conf.pubkey;
          privkey_file = secgen.key;
          interface = name;
          local = spec.local;
        };
      };

      # maybe make configurable later.
      keepalive = false;
      subnet_mask = "/32";
    });
  in {
    lib.l3mon.networks = {
      physical = mapAttrs (network_name: network_spec: map_phys_network network_spec) cfg.physical;
      virtual  = mapAttrs (network_name: network_spec: map_virt_network network_name network_spec) cfg.virtual;
      remote   = mapAttrs (network_name: network_spec: map_remote_network network_name network_spec) cfg.remote;
    };
    l3mon.secgen.secrets =
      (attrsets.foldlAttrs (acc: k: v: acc // config.lib.l3mon.secgen.mkWireguardSpecs k (attrNames v.peers)) {} cfg.virtual) //
      (attrsets.foldlAttrs (acc: k: v: acc // config.lib.l3mon.secgen.mkRemoteWireguardSpecs k) {} cfg.remote);
  };
}
