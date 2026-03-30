{ config, lib, pkgs, machine, data, ... }:

let
  wg_net = config.lib.l3mon.networks.virtual.work;
  wg_net_peerconf = wg_net.peers.${machine};
in {
  systemd.network.networks."30-${wg_net.name}" = {
    matchConfig.Name = wg_net.name;
    networkConfig.Address = wg_net_peerconf.address + wg_net.subnet_mask;
  };

  systemd.network.netdevs."30-${wg_net.name}" = {
    netdevConfig = {
      Name = wg_net.name;
      Kind = "wireguard";
    };
    wireguardConfig = {
      PrivateKeyFile=wg_net_peerconf.privkey_file;
    };
    wireguardPeers = [
      {
        AllowedIPs = [
          wg_net.address_range
        ];
        PublicKey = wg_net.host.pubkey;
        # create all routes.
        RouteTable = "main";
        Endpoint = wg_net.host.endpoint;
        # 0 disables.
        PersistentKeepalive = if wg_net.keepalive then 60 else 0;
      }
    ];
  };
}
