{ config, lib, pkgs, machine, data, ... }:

let 
  ovpn_conf_unibonn_header = pkgs.writeText "ovpn_unibonn" ''
    ##############################################
    # This is a OpenVPN Profile for the          #
    # Computer Science Institute and the B-IT    #
    # of the University of Bonn.                 #
    ##############################################

    client
    dev tun
    proto tcp
    remote bifrost.bit.uni-bonn.de 7073
    resolv-retry infinite
    nobind

    # route entire unibonn address space through vpn.
    route-nopull
    route 131.220.0.0 255.255.0.0
    # exclude gateway from vpn!
    route 131.220.148.199 255.255.255.255 net_gateway

    askpass ${config.l3mon.secgen.secrets.univpn.passphrase}

    # Downgrade privileges after initialization (non-Windows only)
    # The user specified here should exist! If not, create it or
    # replace it with the most unprivileged account on your 
    # linux distribution of choice.
    user nobody
    group nobody

    persist-key
    persist-tun
    remote-cert-tls server
    cipher AES-256-CBC
    auth SHA512


    # Set log file verbosity.
    verb 5

    # Here comes the certificate data...
  '';
in {
  services.openvpn.servers = {
    unibonn.config = "config ${config.l3mon.secgen.secrets.univpn.ovpn_conf}";
  };
  # log in once with root!
  fileSystems."/mnt/wildhorn" = {
    device = "katz@wildhorn.cs.uni-bonn.de:/";
    fsType = "sshfs";
    # only mount on-demand.
    options = [ "noauto" "nodev" "noatime" "allow_other" "ro" "IdentityFile=/var/secrets/id_rsa" "uid=1000" "gid=1000" "x-systemd-requires=openvpn-unibonn.service" ];
  };

  l3mon.secgen.secrets.univpn = rec {
    ovpn_conf = "${config.l3mon.secgen.secret_dir}/univpn_conf";
    passphrase = "${config.l3mon.secgen.secret_dir}/univpn_passphrase";

    backup_files = [ ovpn_conf passphrase ];
    gen = pkgs.writeShellApplication {
      name = "gen";
      runtimeInputs = with pkgs; [ openssl ];
      text = ''
        CONFPATH=""
        PASSPHRASE=""

        echo 'Generate config on https://wumi.cs.uni-bonn.de/en/wumi/home and enter its path:'
        read -r CONFPATH

        echo 'Enter chosen passphrase:'
        read -r PASSPHRASE

        echo -n "$PASSPHRASE" > "${passphrase}"
        chown root:root "${passphrase}"
        chmod 400 "${passphrase}"

        cp "${ovpn_conf_unibonn_header}" "${ovpn_conf}"
        grep -Pzo '(?m)<ca>\n(.*\n)+<\/key>' "$CONFPATH" >> "${ovpn_conf}"
        chown root:root "${ovpn_conf}"
        chmod 400 "${ovpn_conf}"
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "d /mnt/wildhorn"
  ];
}
