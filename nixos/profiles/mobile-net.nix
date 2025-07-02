{ config, lib, pkgs, data, machine, ... }:

let 
  lan = data.network.lan;
  home_wg_net = data.network.wireguard_home2;
  home_wg_net_peerconf = data.network.wireguard_home2.peers.${machine};
  blocky_address = "127.0.0.1";
in {
  networking.hostName = machine;

  # can still be per-case enabled via systemd.
  networking.useDHCP = false;
  networking.firewall.enable = false;

  systemd.network.enable = true;
  systemd.network.networks."10-homenet" = {
    matchConfig.Name = lan.peers."${machine}".interface;
    matchConfig.SSID = "\"${lan.ssid}\"";
    networkConfig.Address = lan.peers."${machine}".address + lan.subnet_mask;
    networkConfig.Gateway = lan.gateway;
    networkConfig.DHCP = false;
    networkConfig.IPv6AcceptRA = false;
    networkConfig.LinkLocalAddressing = false;
    networkConfig.DNS = lan.dns;
    networkConfig.DNSOverTLS = false;
    networkConfig.DNSSEC = false;
  };

  systemd.network.networks."20-nonhomenet" = {
    matchConfig.Name = lan.peers."${machine}".interface;
    networkConfig.DHCP = true;
    dhcpV4Config.UseDNS = false;
    dhcpV6Config.UseDNS = false;
    # connect to blocky-wg_home2.
    networkConfig.DNS = blocky_address;
    networkConfig.DNSOverTLS = false;
    networkConfig.DNSSEC = false;
  };

  systemd.network.networks."30-${home_wg_net.name}" = {
    matchConfig.Name = home_wg_net.name;
    networkConfig.Address = home_wg_net_peerconf.address + home_wg_net.subnet_mask;
  };

  systemd.network.netdevs."30-${home_wg_net.name}" = {
    netdevConfig = {
      Name = home_wg_net.name;
      Kind = "wireguard";
    };
    wireguardConfig = {
      PrivateKeyFile=home_wg_net_peerconf.privkey_file;
    };
    wireguardPeers = [
      {
        AllowedIPs = [
          home_wg_net.address_range
        ];
        PublicKey = home_wg_net.host.pubkey;
        # create all routes.
        RouteTable = "main";
        Endpoint = home_wg_net.host.endpoint;
        # 0 disables.
        PersistentKeepalive = if home_wg_net.keepalive then 60 else 0;
      }
    ];
  };
  
  systemd.services.blocky-wg_home2 = config.l3mon.blocky.mkService {
    conf = config.l3mon.blocky.mkConfig {
      ports = [ "${blocky_address}:53" ];
      network = data.network.wireguard_home2;
      block = false;
      upstream = [ "https://one.one.one.one/dns-query" "https://dns0.eu" ];
    };
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
