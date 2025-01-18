wg_network: { config, lib, pkgs, machine, data, ... }:

with lib;
let
  machine_conf = wg_network."${machine}";
  netns_name = "${wg_network.name}";
  interface_name = "${wg_network.name}";
  dns = "${wg_network.dns}";
  address = "${machine_conf.address}";

  lan_interface = data.network.lan."${machine}".interface;
  lan_ip = data.network.lan."${machine}".address;

  route_local = machine_conf ? local_address;
  local_address = "${machine_conf.local_address}";
  # remove /xx from local ip.
  route_local_address = builtins.substring 0 ((builtins.stringLength local_address) - 2) local_address + "32";
  disallow_local_macvlan = pkgs.writeTextFile {
    name = "rules.conf";
    text = ''
      table ip my_filter {
          chain output {
              type filter hook output priority 0; policy accept;
              ip daddr != ${data.network.lan.address_range} oifname "macvlan_netns" drop
              accept
          }
      }
    '';
  };
in 
{
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
  systemd.services."netns-${netns_name}" = {
    description = "Start network namespace with wireguard-connection.";
    requires = [ "network-online.target" ] ++ (if route_local then ["root_macvlan.service"] else []);
    after = [ "network-online.target" ] ++ (if route_local then ["root_macvlan.service"] else []);
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [
      # for wg, nft, resolvectl, ip
      pkgs.wireguard-tools
      pkgs.nftables
      pkgs.systemd
      pkgs.iproute2
      pkgs.gnused
      pkgs.procps
      pkgs.coreutils
    ];
    script = ''
      set -eE -o functrace

      # for debugging!
      failure() {
        local lineno=$1
        local msg=$2

        echo "Failed at $lineno: $msg"
        echo "Cleaning up"

        "ip netns delete ${netns_name} || true"
        ${optionalString route_local "ip route delete ${route_local_address} || true"}
      }
      trap 'failure $LINENO "$BASH_COMMAND"' ERR
      
      ip netns add ${netns_name}
      ip link add ${interface_name} type wireguard

      resolvectl dns ${interface_name} ${dns} || :
      resolvectl default-route ${interface_name} false || :
      resolvectl dnssec ${interface_name} no || :
      resolvectl dnsovertls ${interface_name} no || :

      # send all traffic over connection.
      wg set ${interface_name} \
        private-key ${machine_conf.privkey_file} \
        peer ${wg_network.host.pubkey} \
        endpoint ${wg_network.host.endpoint} \
        ${optionalString wg_network.keepalive "persistent-keepalive 60"} \
        allowed-ips 0.0.0.0/0

      ip link set ${interface_name} netns ${netns_name}

      ip -n ${netns_name} address add ${address} dev ${interface_name}


      ip -n ${netns_name} link set ${interface_name} up
      ip -n ${netns_name} link set lo up
      ip -n ${netns_name} route add default dev ${interface_name}

      ${optionalString route_local ''
        ip link add link ${lan_interface} name macvlan_netns netns ${netns_name} type macvlan mode bridge
        ip -n ${netns_name} link set macvlan_netns up

        ip -n ${netns_name} addr add ${local_address} dev macvlan_netns
        # extract xxx.xxx.xxx.xxx/ from xxx.xxx.xxx.xxx/xx, append /32, s.t.
        # only the exact ip is routed over the macvlan.
        ip route add ${route_local_address} dev macvlan_root

        # disable ipv4 with destination outside the local network on the interface.
        ip netns exec ${netns_name} nft -f ${disallow_local_macvlan}
        ip netns exec ${netns_name} sysctl -w net.ipv6.conf.macvlan_netns.disable_ipv6=1
      ''}

      mkdir -p /etc/netns/${netns_name}/
      echo "nameserver ${dns}" > /etc/netns/${netns_name}/resolv.conf
      cp /etc/nsswitch.conf /etc/netns/${netns_name}/nsswitch.conf

      # disable systemd-resolved direct-call in namespace.
      # This leaves dbus, but that should be redirected to the correct dns
      # server due to the resolvectl call before.
      sed 's/resolve \[!UNAVAIL=return\] //' -i /etc/netns/${netns_name}/nsswitch.conf
    '';
    preStop = ''
      ${optionalString route_local "ip route delete ${route_local_address} || true"}

      ip netns delete ${netns_name} || true
    '';
  };
}
