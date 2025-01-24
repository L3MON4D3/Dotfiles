{ config, lib, pkgs, data, machine, ... }:

let 
  lan = data.network.lan;
in
{
  networking.hostName = machine;
  networking.useDHCP = false;
  networking.firewall.enable = false;

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
