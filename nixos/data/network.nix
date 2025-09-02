let
  ports = import ./ports.nix;
in rec {
  lan = {
    subnet_mask = "/24";
    address_range = "192.168.178.0/24";
    dns = "192.168.178.20";
    gateway = "192.168.178.1";
    ssid = "FRITZ!Box 5590 RM";
    peers = {
      fritzbox = {
        machine_id = "fritzbox";
        address = "192.168.178.1";
        services = [
          "fritzbox"
        ];
      };
      prusamini = {
        machine_id = "prusamini";
        address = "192.168.178.13";
        services = [
          "prusamini"
        ];
      };
      teal = {
        address = "192.168.178.6";
        interface = "enp34s0";
      };
      carmine = {
        machine_id = "carmine";
        address = "192.168.178.21";
        phys_interface = "enp34s0";
        phys_mac = "00:d8:61:53:a8:63";
        interface = "venp34s0";
        mac = "02:44:3a:85:35:ae";
        services = [
          "cache.carmine"
        ];
      };
      cobalt = {
        machine_id = "cobalt";
        address = "192.168.178.22";
        interface = "wlo1";
      };
      carmine_mullvad_de = {
        address = "192.168.178.41";
        mac_address = "30:e4:58:0a:6e:fc";
      };
      cinnabar = {
        address = "192.168.178.5";
      };
      indigo = {
        machine_id = "indigo";
        address = "192.168.178.20";
        phys_interface = "enp0s31f6";
        phys_mac = "70:85:c2:01:58:04";
        interface = "venp0s31f6";
        mac = "02:b5:0d:d2:90:a5";
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
          "cache.indigo"
          "kk"
          "readeck"
          "mealie"
          "pinchflat"
          "kiwix"
          "zimit"
          "linkding"
        ];
      };
      remarkable = {
        address = "192.168.178.10";
      };
      indigo_mullvad_de = {
        address = "192.168.178.40";
        mac_address = "5e:42:b0:71:f7:1b";
      };
      merigold = {
        machine_id = "merigold";
        address = "192.168.178.30";
        mac_address = "02:46:6b:e0:7d:24";
      };
      merigold-test = {
        machine_id = "merigold-test";
        address = "192.168.178.31";
        mac_address = "02:b6:c0:23:7f:08";
        services = [
          "nix-cache.internal"
        ];
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
        endpoint = "wireguard.l3mon4.de:${toString ports.wireguard_home}";
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
      cobalt = {
        address = "10.0.0.10";
        route_all = false;
        privkey_file = "/var/secrets/wg_home2/cobalt-private";
        pubkey = "E9QdhpakA8gw0Ke0DshdcauMrV7P2MtURr4EJYEWgns=";
      };
      chromecast = {
        address = "10.0.0.7";
        route_all = false;
        privkey_file = "/var/secrets/wg_home2/chromecast-private";
        pubkey = "Ticy/93/8Mk53wysWLmkTiZpnt1i/I7mNqxJT2Dw+3Q=";
      };
      kim-laptop = {
        address = "10.0.0.8";
        route_all = false;
        privkey_file = "/var/secrets/wg_home2/kim-laptop-private";
        pubkey = "pAvekTUd9Rbke/cPqhY+xcVVR/fdkaADAfi+7uDKrU0=";
      };
      kim-desktop = {
        address = "10.0.0.9";
        route_all = false;
        privkey_file = "/var/secrets/wg_home2/kim-desktop-private";
        pubkey = "SxVbXOA29ekQUJHS7yE342HFXKMRvlBiMnEgZvEPwXs=";
      };
    };
  };

  wireguard_mullvad_de = rec {
    subnet_mask = "/32";
    name = "wg_mullvad_de";
    peers = {
      indigo = {
        address = "10.74.224.236";
        privkey_file = "/var/secrets/wireguard_mullvad/de_neat_ibex.private";
        pubkey = "+nqH8e7xvI4+sfAt2r0Y8C1e8ZfiXDqS0b3wHm00ilU=";
        local = lan.peers.indigo_mullvad_de;
        interface = name;
        # for now, these are the same here and in the lan-part.
        # Maybe, at some time, I want to make services no longer accessible in
        # both networks, at that point I'll have to keep this in sync with the
        # services in indigo_mullvad_de manually.
        services = lan.peers.indigo_mullvad_de.services;
      };
      mullvad = {
        endpoint = "146.70.117.2:51820";
        pubkey = "Sttn2cr14dvIcCrE8qdlRGHXriqvTyvQWC7dzujH/iM="; 
      };
    };
    host = peers.mullvad;
    keepalive = false;
    dns = "10.64.0.1";
  };

  wireguard_mv_cb_de = rec {
    subnet_mask = "/32";
    name = "wg_mv_cb_de";
    peers = {
      cobalt = {
        address = "10.71.102.201";
        privkey_file = "/var/secrets/wireguard_mullvad/de_bright_mole.private";
        pubkey = "kOwz+tFnMo1XcM+Qhecln5iyDg3/5TAhS4Yq46ieL00=";
        interface = name;
      };
      mullvad = {
        endpoint = "169.150.201.15:51820";
        pubkey = "6/PBbPtoeWpJA+HZc9Iqg/PPQWD7mGVvZdwQlr1vtRk="; 
      };
    };
    host = peers.mullvad;
    keepalive = false;
    dns = "10.64.0.1";
  };

  wireguard_rec_de = rec {
    subnet_mask = "/24";
    name = "wg_rec_de";
    dns = "10.0.1.1";
    address_range = "10.0.1.0/24";
    host = peers.indigo;
    keepalive = true;
    peers = {
      indigo = {
        # indigo
        machine_id = "indigo";
        endpoint = "wireguard.l3mon4.de:${toString ports.wireguard_rec_de}";
        address = "10.0.1.1";
        privkey_file = "/var/secrets/wg_rec_de/indigo-private";
        pubkey = "JttJ05OOG8eT+dv/JblhpNyS3IfKiYhQ/EFCJe1hLEc=";
      };
      carmine = {
        address = "10.0.1.2";
        route_all = true;
        local = lan.peers.carmine_mullvad_de;
        privkey_file = "/var/secrets/wg_rec_de/carmine-private";
        pubkey = "piXA8QVYisipkz2zMn7vpsZq6okSjHNwnt4sLMykRXk=";
      };
      cobalt = {
        address = "10.0.1.3";
        route_all = true;
        privkey_file = "/var/secrets/wg_rec_de/cobalt-private";
        pubkey = "qck0Vt58kCDrat48urQrQcQJ5/KL1dH8VtM4Niniw00=";
      };
    };
  };
}
