rec {
  lan = {
    subnet_mask = "/24";
    address_range = "192.168.178.0/24";
    dns = "192.168.178.5";
    gateway = "192.168.178.1";
    peers = {
      fritzbox = {
        address = "192.168.178.1";
      };
      teal = {
        address = "192.168.178.6";
        interface = "enp34s0";
      };
      indigo = {
        address = "192.168.178.20";
        interface = "ens3";
        services = [
          "mysql"
        ];
      };
      indigo_mullvad_de = {
        address = "192.168.178.40";
        services = [
          "jackett"
          "radarr"
          "sonarr"
          "qbittorrent"
        ];
      };
    };
  };

  wireguard_home2 = rec {
    subnet_mask = "/24";
    name = "wg_home2";
    dns = "10.0.0.1";
    host = peers.indigo;
    peers = {
      indigo = {
        # indigo
        endpoint = "l3mon4.de:51822";
        address = "10.0.0.1";
        privkey_file = "/var/secrets/wireguard_home2/indigo_private";
        pubkey = "UjwW2Cd7RbHlS+E7iKq1Igez+325QyxYm7wu3HseCRo=";
        services = lan.peers.indigo.services;
      };
      teal = {
        address = "10.0.0.2";
        privkey_file = "/var/secrets/wireguard_home2/teal_private";
        pubkey = "zJsfvvuFCh5AK2/wl4TZZZlWz2l4SM9fEdWy2mea/0c=";
      };
    };
  };

  wireguard_home = rec {
    subnet_mask = "/24";
    name = "wg_home";
    host = peers.cinnabar;
    dns = "10.0.0.1";
    keepalive = true;
    peers = {
      cinnabar = {
        address = "10.0.0.1";
        endpoint = "l3mon4.de:51822";
        pubkey = "crcxsmvCRMSSY+ixB5p07MzxSv0xDmHPHBmd2w7mNyg=";
      };
      indigo = {
        address = "10.0.0.7";
        privkey_file = "/var/secrets/wireguard_home/indigo_private";
        pubkey = "ln4vj6cBDF5FuJlqpUpNOq5nubesA7bR0HQE3PV2/DI=";
      };
    };
  };
  wireguard_mullvad_de = rec {
    subnet_mask = "/32";
    name = "wg_mullvad_de";
    peers = {
      indigo = {
        address = "10.71.192.70";
        privkey_file = "/var/secrets/wireguard_mullvad/de_unique_worm.private";
        pubkey = "9ldhvN7r4xGZkGehbsNfYb5tpyTJ5KBb5B3TbxCwklw=";
        local = lan.peers.indigo_mullvad_de;
        # for now, these are the same here and in the lan-part.
        # Maybe, at some time, I want to make services no longer accessible in
        # both networks, at that point I'll have to keep this in sync with the
        # services in indigo_mullvad_de manually.
        services = lan.peers.indigo_mullvad_de.services;
      };
      mullvad = {
        endpoint = "146.70.117.34:51820";
        pubkey = "9ldhvN7r4xGZkGehbsNfYb5tpyTJ5KBb5B3TbxCwklw="; 
      };
    };
    host = peers.mullvad;
    keepalive = false;
    dns = "10.64.0.1";
  };
}
