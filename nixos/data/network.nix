rec {
  lan = {
    subnet_mask = "/24";
    address_range = "192.168.178.0/24";
    dns = "192.168.178.20";
    gateway = "192.168.178.1";
    peers = {
      fritzbox = {
        address = "192.168.178.1";
      };
      teal = {
        address = "192.168.178.6";
        interface = "enp34s0";
      };
      carmine = {
        machine_id = "carmine";
        address = "192.168.178.21";
        interface = "enp34s0";
      };
      cinnabar = {
        address = "192.168.178.5";
      };
      indigo = {
        machine_id = "indigo";
        address = "192.168.178.20";
        interface = "enp0s31f6";
        services = [
          "mysql"
          "jackett"
          "radarr"
          "sonarr"
          "qbittorrent"
          "jellyfin"
          "git"
          "immich"
          "paperless"
          "rmfakecloud"
          "zotero"
          "radicale"
          "webdav"
          "restic"
        ];
      };
      indigo_mullvad_de = {
        address = "192.168.178.40";
      };
    };
  };

  wireguard_home2 = rec {
    subnet_mask = "/24";
    name = "wg_home2";
    dns = "10.0.0.1";
    host = peers.indigo;
    address_range = "10.0.0.0/24";
    keepalive = true;
    peers = {
      indigo = {
        # indigo
        machine_id = "indigo";
        endpoint = "192.168.178.20:51822";
        address = "10.0.0.1";
        privkey_file = "/var/secrets/wg_home2/indigo-private";
        pubkey = "UjwW2Cd7RbHlS+E7iKq1Igez+325QyxYm7wu3HseCRo=";
        # for now, these are identical.
        services = lan.peers.indigo.services;
      };
      teal = {
        address = "10.0.0.2";
        route_all = true;
        privkey_file = "/var/secrets/wg_home2/teal-private";
        pubkey = "zJsfvvuFCh5AK2/wl4TZZZlWz2l4SM9fEdWy2mea/0c=";
      };
      canary = {
        address = "10.0.0.3";
        route_all = false;
        privkey_file = "/var/secrets/wg_home2/canary-private";
        pubkey = "2aaQykUGo4CQy1scam16F89flkPDMxu/qVV/cY+7tTM=";
      };
      xperia = {
        address = "10.0.0.4";
        route_all = true;
        privkey_file = "/var/secrets/wg_home2/xperia-private";
        pubkey = "mrQt6UqR0HpJVGXp6qfVEATDVTzm80RHYks6wqETCEk=";
      };
      remarkable = {
        address = "10.0.0.5";
        route_all = true;
        privkey_file = "/var/secrets/wg_home2/remarkable-private";
        pubkey = "Udk2A6dop+5xOrRmwBqkQ5CGJexC3hteTKYErhjvTTw=";
      };
      carmine = {
        address = "10.0.0.6";
        route_all = true;
        privkey_file = "/var/secrets/wg_home2/carmine-private";
        pubkey = "iGurYHJ9mfYU5y1khcH6T35zIOPogUpvvqJgrY9rWSg=";
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
        endpoint = "192.168.178.5:51822";
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
        pubkey = "7GMMTVf8zhDOxQYIAwDoKcd2fqwOwxrkz4ENqg3jwyQ=";
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
  wireguard_mullvad_de2 = rec {
    subnet_mask = "/32";
    name = "wg_mullvad_de";
    peers = {
      carmine = {
        address = "10.74.105.235";
        privkey_file = "/var/secrets/wireguard_mullvad/de_master_tomcat.private";
        pubkey = "RZf+O56iD/WHM4uiURYcPNtwKbL3r4QvNKSWdoEhX2g=";
      };
      mullvad = {
        endpoint = "193.32.248.75:51820";
        pubkey = "/ejdxiEsmYbeXXCN6UzvzJ0U/mLuB6baIfQRYKYHWzU="; 
      };
    };
    host = peers.mullvad;
    keepalive = false;
    dns = "10.64.0.1";
  };
}
