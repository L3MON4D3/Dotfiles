{
  lan = {
    teal = {
      address = "192.168.178.6/24";
      interface = "enp34s0";
    };
    indigo = {
      address = "192.168.178.20/24";
      interface = "ens3";
    };
    dns = "192.168.178.5";
    gateway = "192.168.178.1";
    address_range = "192.168.178.0/24";
  };
  wireguard_home2 = {
    name = "wg_home2";
    host = {
      # indigo
      endpoint = "l3mon4.de:51822";
      address = "10.0.0.1/24";
      privkey_file = "/var/secrets/wireguard_home2/indigo_private";
      pubkey = "UjwW2Cd7RbHlS+E7iKq1Igez+325QyxYm7wu3HseCRo=";
    };
    teal = {
      address = "10.0.0.2/24";
      privkey_file = "/var/secrets/wireguard_home2/teal_private";
      pubkey = "zJsfvvuFCh5AK2/wl4TZZZlWz2l4SM9fEdWy2mea/0c=";
    };
    dns = "10.0.0.1";
  };
  wireguard_home = {
    name = "wg_home";
    host = {
      # cinnabar
      endpoint = "l3mon4.de:51822";
      pubkey = "crcxsmvCRMSSY+ixB5p07MzxSv0xDmHPHBmd2w7mNyg=";
    };
    indigo = {
      address = "10.0.0.7/24";
      privkey_file = "/var/secrets/wireguard_home/indigo_private";
      pubkey = "ln4vj6cBDF5FuJlqpUpNOq5nubesA7bR0HQE3PV2/DI=";
    };
    keepalive = true;
    dns = "10.0.0.1";
  };
  wireguard_mullvad_de = {
    name = "wg_mullvad_de";
    indigo = {
      address = "10.71.192.70/32";
      privkey_file = "/var/secrets/wireguard_mullvad/de_unique_worm.private";
      pubkey = "9ldhvN7r4xGZkGehbsNfYb5tpyTJ5KBb5B3TbxCwklw=";
      local_address = "192.168.178.40/24";
    };
    host = {
      endpoint = "146.70.117.34:51820";
      pubkey = "9ldhvN7r4xGZkGehbsNfYb5tpyTJ5KBb5B3TbxCwklw="; 
    };
    keepalive = false;
    dns = "10.64.0.1";
  };
}
