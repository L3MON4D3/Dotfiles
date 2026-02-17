# TODO: separate dhcp (give 1.1.1.1 as dns) for guest devices!
# Realise by generating separate dhcp for a "lan.x" where x is the vlan
# tag of the guest network.

{ networks, ... }: {
  # make sure odhcpcd-ipv6only is uninstalled.
  packages = [ "odhcpd" ];
  uci.settings = {
    dhcp = {
      # clear dnsmasq settings; we don't need it.
      dnsmasq = {};
      odhcpd.odhcpd = {
        maindhcp = true;
      };
      dhcp.lan = {
        interface = "lan";
        start = 100;
        limit = 200;
        leasetime = "12h";
        dhcpv4 = "server";
        dhcpv6 = "server";
        dns = networks.physical.home.dns;
      };
      host = [
        {
          ip = networks.physical.home.peers.xperia.address;
          mac = networks.physical.home.peers.xperia.mac;
          name = "xperia";
        }
      ];
    };
  };
}
