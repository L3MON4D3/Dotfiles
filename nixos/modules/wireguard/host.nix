{ config, lib, pkgs, machine, data, ... }:
  
with lib;
let
  cfg = config.l3mon.wg-quick-hosts;
in {
  options.l3mon.wg-quick-hosts = {
    enable = mkEnableOption (lib.mdDoc "Create wireguard-interfaces in global namespace.");

    network_configs = mkOption {
      type = with types; listOf attrs;
      description = lib.mdDoc "List of wireguard-networks as defined in ./data/networks.";
      default = [];
    };
  };

  config = mkIf cfg.enable (let
    lan_interface = data.network.lan."${machine}".interface;
    lan_ip = data.network.lan."${machine}".address;
  in {
    networking.nat.enable = true;
    networking.wg-quick.interfaces = builtins.listToAttrs (map (
      wg_network: let
        machine_conf = wg_network.host;
        peernames = builtins.filter (x:
          x != "dns" &&
          x != "name" &&
          x != "host") (builtins.attrNames wg_network);
      in {
        name = "${wg_network.name}";
        value = {
          address = [machine_conf.address];
          listenPort = lib.strings.toInt (builtins.elemAt (builtins.split ":" machine_conf.endpoint) 2);
          privateKeyFile = machine_conf.privkey_file;
          postUp = ''
            ${pkgs.iptables}/bin/iptables -A FORWARD -i ${wg_network.name} -j ACCEPT
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${machine_conf.address} -o ${data.network.lan."${machine}".interface} -j MASQUERADE
          '';
          preDown = ''
            ${pkgs.iptables}/bin/iptables -D FORWARD -i ${wg_network.name} -j ACCEPT
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${machine_conf.address} -o ${data.network.lan."${machine}".interface} -j MASQUERADE
          '';
          peers = builtins.map (peername: let peerconf = wg_network."${peername}"; in {
            publicKey = peerconf.pubkey;
            allowedIPs = [peerconf.address];
          }) peernames;
        };
      }
    ) cfg.network_configs);
  });
}
