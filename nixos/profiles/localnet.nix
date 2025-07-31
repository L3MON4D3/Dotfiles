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
  systemd.network.networks."10-lan" = {
    matchConfig.Name = lan.peers."${machine}".interface;
    networkConfig.Address = lan.peers."${machine}".address + lan.subnet_mask;
    networkConfig.Gateway = lan.gateway;
    networkConfig.DHCP = false;
    networkConfig.IPv6AcceptRA = false;
    networkConfig.LinkLocalAddressing = false;
    networkConfig.DNS = lan.dns;
    networkConfig.DNSOverTLS = false;
    networkConfig.DNSSEC = false;
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
