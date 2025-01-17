wg_network: { config, lib, pkgs, machine, data, ... }:

let
  machine_conf = wg_network.host;
  peernames = builtins.filter (x:
    x != "dns" &&
    x != "name" &&
    x != "host") (builtins.attrNames wg_network);
in 
{
  networking.nat.enable = true;
  networking.wg-quick.interfaces = {
    "${wg_network.name}" = {
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
  };
}
