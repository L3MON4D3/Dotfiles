{ config, lib, pkgs, machine, data, inputs, system, ... }:

with lib;
let
  cfg = config.l3mon.network_namespaces;
in {
  options.l3mon.network_namespaces = {
    enable = mkEnableOption (lib.mdDoc "Create network-namespaces for passed networks.");

    network_configs = mkOption {
      type = with types; listOf attrs;
      description = lib.mdDoc "List of wireguard-networks as defined in ./data/networks.";
      default = [];
    };

    mkNetnsService = mkOption {
      type = types.anything;
      description = lib.mdDoc ''
      Call this with a wireguard-network definition
      and a systemd-service attrset to create a systemd-service confined to the
      network-namespace.
      '';
      readOnly = true;
    };
  };

  config = mkIf cfg.enable (let
    lan_interface = data.network.lan.peers."${machine}".interface;
    lan_ip = data.network.lan.peers."${machine}".address + data.network.lan.subnet_mask;
  in {
    systemd.services = builtins.listToAttrs (lib.concatMap (
      wg_network: let
        machine_conf = wg_network.peers."${machine}";
        netns_name = "${wg_network.name}";
        interface_name = "${wg_network.name}";
        dns = "${wg_network.dns}";
        address = machine_conf.address + wg_network.subnet_mask;

        route_local = machine_conf ? local;
        local_peer = machine_conf.local;
        local_address = local_peer.address + data.network.lan.subnet_mask;
        route_local_address = "${local_peer.address}/32";
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
      in [
        {
          name = "netns-${netns_name}";
          value = {
            description = "Start network namespace with wireguard-connection.";
            requires = [ "network-online.target" ] ++ (if route_local then [ "root_macvlan.service" ] else []);
            after = [ "network-online.target" ] ++ (if route_local then ["root_macvlan.service"] else []);
            # only start blocky once the network-namespace exists.
            before = (if route_local then ["blocky-${netns_name}.service"] else []);
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
                # only route the exact ip over the macvlan.
                ip route add ${route_local_address} dev macvlan_root

                # disable ipv4 with destination outside the local network on the interface.
                ip netns exec ${netns_name} nft -f ${disallow_local_macvlan}
                ip netns exec ${netns_name} sysctl -w net.ipv6.conf.macvlan_netns.disable_ipv6=1
              ''}

              mkdir -p /etc/netns/${netns_name}/
              echo "nameserver ${if route_local then "127.0.0.1" else dns}" > /etc/netns/${netns_name}/resolv.conf
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
      ] ++ (if route_local then
        [{
            name = "blocky-${netns_name}";
            value = config.l3mon.network_namespaces.mkNetnsService wg_network (config.l3mon.blocky.mkService {
              conf = config.l3mon.blocky.mkConfig {
                ports = ["127.0.0.1:53"];
                network = data.network.lan;
                block = false;
                upstream = [ dns ];
              };
            });
        }]
      else
        [ ])
      ) cfg.network_configs ) // {
        root_macvlan = {
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
      };

      security.wrappers = {
        netns-exec = {
          setuid = true;
          owner = "root";
          group = "root";
          source = "${inputs.netns-exec.defaultPackage.${system}}/bin/netns-exec";
        };
      };
      environment.systemPackages = with pkgs; [
        # completions.
        inputs.netns-exec.defaultPackage.${system}
      ];

      l3mon.network_namespaces.mkNetnsService = (wg_network: service: lib.mkMerge [
        service
        (
          let
            netns_name = wg_network.name;
          in {
            bindsTo = [ "netns-${netns_name}.service" ];
            after = ["netns-${netns_name}.service" ];
            serviceConfig = {
              # disable network-name-lookup via nscd and nsswitch, and provide
              # resolv.conf with vpn-provided dns.
              BindPaths = [
                "/var/empty:/var/run/nscd"
                # NetworkNamespacePath= does not mount /etc/netns/-provided files.
                # This is something done explicitly by `ip netns exec`.
                "/etc/netns/${netns_name}/resolv.conf:/etc/resolv.conf"
                "/etc/netns/${netns_name}/nsswitch.conf:/etc/nsswitch.conf"
              ];
              NetworkNamespacePath = "/var/run/netns/${netns_name}";
            };
          }
        )
      ]);
    });
}
