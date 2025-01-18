{ config, lib, pkgs, machine, data, ... }:

let
  lan_interface = data.network.lan."${machine}".interface;
  lan_ip = data.network.lan."${machine}".address;
in {
  systemd.services.root_macvlan = {
    description = "Add macvlan interface for connecting into network-namespaces.";
    requires = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [
      # for resolvectl, ip.
      pkgs.systemd
      pkgs.iproute2
      pkgs.procps
    ];
    script = ''
      ip link add link ${lan_interface} name macvlan_root type macvlan mode bridge

      resolvectl default-route macvlan_root false || :

      sysctl -w net.ipv6.conf.macvlan_root.autoconf=0
      sysctl -w net.ipv6.conf.macvlan_root.accept_ra=0

      ip addr add ${lan_ip} dev macvlan_root noprefixroute
      ip link set dev macvlan_root up
    '';
    preStop = ''
      ip link delete macvlan_root
    '';
  };
}
