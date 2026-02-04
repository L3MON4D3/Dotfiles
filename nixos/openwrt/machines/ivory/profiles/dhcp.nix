{ networks, ... }: {
  # TODO: separate dhcp (give 1.1.1.1 as dns) for guest devices!
  # Realise by generating separate dhcp for a "lan.x" where x is the vlan
  # tag of the guest network.
  uci.settings = {
    dhcp = {
      odhcpcd.odhcpcd = {
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
    };
  };
}
