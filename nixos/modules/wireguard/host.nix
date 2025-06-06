{ config, lib, pkgs, machine, data, ... }:
  
with lib;
let
  cfg = config.l3mon.wg-quick-hosts;
in {
  options.l3mon.wg-quick-hosts = {
    enable = mkEnableOption (lib.mdDoc "Create wireguard-interfaces in global namespace.");

    specs = mkOption {
      type = with types; listOf attrs;
      description = lib.mdDoc "List of attrset with key config a wireguard-network as defined in ./data/networks, and key netns another wireguard-network, which has to enable a netns.";
      default = [];
    };
  };

  config = mkIf cfg.enable (let
    # out_interface = data.network.lan.peers."${machine}".interface;
    out_interface = "wg_mullvad_de";
  in {
    networking.nat.enable = true;

    networking.wg-quick.interfaces = builtins.listToAttrs (map (
      spec: let
        wg_network = spec.config;
        out_network = if spec ? netns then spec.netns else data.network.lan;
        out_interface = out_network.peers.${machine}.interface;
        machine_conf = wg_network.host;
        full_address = machine_conf.address + wg_network.subnet_mask;
        peernames = builtins.filter (x: x != machine) (builtins.attrNames wg_network.peers);
      in {
        name = "${wg_network.name}";
        value = {
          address = [(machine_conf.address + wg_network.subnet_mask)];
          listenPort = lib.strings.toInt (builtins.elemAt (builtins.split ":" machine_conf.endpoint) 2);
          privateKeyFile = machine_conf.privkey_file;
          postUp = ''
            ${pkgs.iptables}/bin/iptables -A FORWARD -i ${wg_network.name} -j ACCEPT
            ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${full_address} -o ${out_interface} -j MASQUERADE
          '';
          preDown = ''
            ${pkgs.iptables}/bin/iptables -D FORWARD -i ${wg_network.name} -j ACCEPT
            ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${full_address} -o ${out_interface} -j MASQUERADE
          '';
          peers = builtins.map (peername: let peerconf = wg_network.peers."${peername}"; in {
            publicKey = peerconf.pubkey;
            # can usually only reach peers directly.
            allowedIPs = ["${peerconf.address}/32"];
          }) peernames;
        };
      }
    ) cfg.specs);

    systemd.services = builtins.listToAttrs (map (
      spec: let
        wg_name = spec.config.name;
      in {
        name = "wg-quick-${wg_name}";
        value = if spec ? netns then (config.l3mon.network_namespaces.mkNetnsService spec.netns {}) else {};
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
