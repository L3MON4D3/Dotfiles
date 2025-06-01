{ config, lib, pkgs, machine, data, ... }:
  
with lib;
let
  cfg = config.l3mon.wg-quick-hosts;
in {
  options.l3mon.wg-quick-hosts = {
    enable = mkEnableOption (lib.mdDoc "Create wireguard-interfaces in global namespace.");

    specs = mkOption {
      type = with types; listOf attrs;
      description = lib.mdDoc "List of attrset with key config a wireguard-network as defined in ./data/networks, and key netns optionally another wireguard-network, which has to enable a netns.";
      default = [];
    };
  };

  config = mkIf cfg.enable (let
    # out_interface = data.network.lan.peers."${machine}".interface;
    out_interface = "wg_mullvad_de";
  in {
    # for forwarding
    networking.nat.enable = true;

    systemd.services = builtins.listToAttrs (map (spec: let
      wg_network = spec.config;
      wg_name = spec.config.name;
      wg_if_network = if spec ? netns then spec.netns else data.network.lan;
      host_conf = wg_network.host;
      full_address = machine_conf.address + wg_network.subnet_mask;
      if_netns_do = if spec ? netns then "ip netns exec ${wg_if_network.name}" else "";
      wg_link_name = "${wg_network.name}";
      listen_port = builtins.elemAt (builtins.split ":" host_conf.endpoint) 2;
      peer_spec_to_args = peerconf: " peer ${peerconf.pubkey} allowed-ips ${peerconf.address}/32";
      peers = pkgs.lib.attrsets.foldlAttrs (acc: k: v: acc ++ (if k != machine then [v] else [])) [] wg_network.peers;
    in {
      name = "host-${wg_network.name}";
      value = {
        description = "Host a wireguard vpn.";
        bindsTo = [ "network-online.target" ] ++ (if spec ? netns then [ "netns-${wg_if_network.name}.service" ] else []);
        after = [ "network-online.target" ] ++ (if spec ? netns then [ "netns-${wg_if_network.name}.service" ] else []);
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        path = with pkgs; [
          iptables
          wireguard-tools
          iproute2
        ];
        script = ''
          ip link add ${wg_link_name} type wireguard
          ${optionalString (spec ? netns) "ip link set ${wg_link_name} netns ${wg_if_network.name}"}
          ${if_netns_do} wg set ${wg_link_name} listen-port ${listen_port} private-key ${host_conf.privkey_file} ${builtins.toString (map peer_spec_to_args peers)}
          ${if_netns_do} ip addr add ${host_conf.address}${wg_network.subnet_mask} dev ${wg_link_name}
          ${if_netns_do} ip link set ${wg_link_name} up
          ${if_netns_do} iptables -A FORWARD -i ${wg_link_name} -o ${wg_if_network.peers.${machine}.interface} -j ACCEPT
          ${if_netns_do} iptables -A FORWARD -o ${wg_link_name} -i ${wg_if_network.peers.${machine}.interface} -j ACCEPT
          ${if_netns_do} iptables -t nat -A POSTROUTING -s ${wg_network.address_range} -o ${wg_if_network.peers.${machine}.interface} -j MASQUERADE
        '';
        postStop = ''
          ${if_netns_do} iptables -t nat -D POSTROUTING -s ${wg_network.address_range} -o ${wg_if_network.peers.${machine}.interface} -j MASQUERADE
          ${if_netns_do} iptables -D FORWARD -i ${wg_link_name} -o ${wg_if_network.peers.${machine}.interface} -j ACCEPT
          ${if_netns_do} iptables -D FORWARD -o ${wg_link_name} -i ${wg_if_network.peers.${machine}.interface} -j ACCEPT
          ${if_netns_do} ip link del ${wg_link_name}
        '';
      };
    }) cfg.specs);

    system.activationScripts = builtins.listToAttrs (map (
      spec: let
        wg_network = spec.config;
        machine_conf = wg_network.host;
        full_address = machine_conf.address + wg_network.subnet_mask;
        peernames = builtins.filter (x: x != machine) (builtins.attrNames wg_network.peers);
      in {
        name = "wg_generate_conf-${wg_network.name}";
        value = {
          text = concatStringsSep "\n" (builtins.map (peername: let
            peerconf = wg_network.peers."${peername}";
            allowed_ips = if peerconf.route_all then "0.0.0.0/0" else wg_network.address_range;
            conf_template = pkgs.writeTextFile {
              name = "conf";
              text = ''
                [Interface]
                PrivateKey = $PEER_PRIVKEY
                Address = ${peerconf.address}${wg_network.subnet_mask}
                DNS = ${wg_network.dns}

                [Peer]
                PublicKey = ${wg_network.host.pubkey}
                ${optionalString wg_network.keepalive "PersistentKeepalive = 60"} 
                AllowedIPs = ${allowed_ips}
                Endpoint = ${wg_network.host.endpoint}
              '';
            };
            conf_target_location = "/etc/wireguard_configs/${wg_network.name}/${peername}.conf";
            wg = if peername == "remarkable" then "/opt/bin/wg" else "wg";
            peer_service = pkgs.writeTextFile {
              name = "service";
              text = ''
                [Unit]
                Description=Minimal wireguard (suited for remarkable).
                After=network-online.target nss-lookup.target
                Requires=network-online.target nss-lookup.target

                [Service]
                Type=oneshot
                RemainAfterExit=yes
                Environment=WG_ENDPOINT_RESOLUTION_RETRIES=infinity
                ExecStart=ip link add ${wg_network.name} type wireguard
                ExecStart=${wg} set ${wg_network.name} private-key ${peerconf.privkey_file} peer ${wg_network.host.pubkey} endpoint ${wg_network.host.endpoint} allowed-ips ${allowed_ips} ${optionalString wg_network.keepalive "persistent-keepalive 60"}
                ExecStart=ip addr add ${peerconf.address}${wg_network.subnet_mask} dev ${wg_network.name}
                ExecStart=ip link set dev ${wg_network.name} up
                ExecStart=ip route add default dev ${wg_network.name}
                ExecStart=bash -c 'echo nameserver ${wg_network.dns} > /etc/resolv_${wg_network.name}'
                # mount as readonly so dhcpcd may not override it!!
                # It tries to as soon as the wifi-connection drops, which is too
                # frequently to leave this unresolved.
                ExecStart=mount --bind -o ro /etc/resolv_${wg_network.name} /etc/resolv.conf

                ExecStop=ip route del default dev ${wg_network.name}
                ExecStop=ip link del ${wg_network.name}
                ExecStop=umount /etc/resolv.conf

                [Install]
                WantedBy=multi-user.target
              '';
            };
          in ''
            mkdir -p /etc/wireguard_configs/${wg_network.name}/
            PEER_PRIVKEY=$(cat ${peerconf.privkey_file}) ${pkgs.envsubst}/bin/envsubst -i ${conf_template} -o ${conf_target_location}
            chmod 400 ${conf_target_location}

            mkdir -p /etc/wireguard_services/
            cp ${peer_service} /etc/wireguard_services/${wg_network.name}-${peername}.service
          '') peernames);
        };
      }
    ) cfg.specs);
  });
}
