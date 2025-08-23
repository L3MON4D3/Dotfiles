{ config, lib, pkgs, data, machine, ... }:

let 
  lan = data.network.lan;
  lan_machine = lan.peers.${machine};
in
{
  networking.hostName = machine;
  networking.useDHCP = false;
  networking.firewall.enable = false;

  networking.interfaces.${lan_machine.interface} = {
    macAddress = lan_machine.mac; 
    wakeOnLan.enable = true;
  };

  systemd.network.enable = true;
  systemd.network.networks = {
    "10-lan" = {
      matchConfig.Name = lan.peers."${machine}".interface;
      # prevent systemd-wait-online for waiting on an ip for this interface.
      linkConfig.RequiredForOnline = "carrier";
      # don't wait for ip-assignment via DHCP.
      networkConfig.DHCP = false;
      networkConfig.IPv6AcceptRA = false;
      networkConfig.LinkLocalAddressing = false;
      networkConfig.MACVLAN = "v${lan.peers."${machine}".interface}";
    };
    "20-vlan" = {
      matchConfig.Name = "v${lan.peers.${machine}.interface}";
      linkConfig.RequiredForOnline = "routable";
      networkConfig.Address = lan.peers."${machine}".address + lan.subnet_mask;
      networkConfig.Gateway = lan.gateway;
      networkConfig.DHCP = false;
      networkConfig.IPv6AcceptRA = false;
      networkConfig.LinkLocalAddressing = false;
      networkConfig.DNS = lan.dns;
      networkConfig.DNSOverTLS = false;
      networkConfig.DNSSEC = false;
      networkConfig.BindCarrier = "${lan.peers.${machine}.interface}";
    };
  };

  systemd.network.netdevs."10-macvlan" = {
    netdevConfig = {
      Name = "v${lan.peers."${machine}".interface}";
      Kind = "macvlan";
    };
    macvlanConfig.Mode = "bridge";
  };

  services.resolved = {
    enable = true;
    dnssec = "true";
    dnsovertls = "true";
    llmnr = "false";
    extraConfig = ''
    ResolveUnicastSingleLabel=true
    '';
  };
}
