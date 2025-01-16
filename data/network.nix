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
  };
  wireguard_home = {
    ifname = "wg_home";
    indigo = {
      address = "10.0.0.1/24";
      privkey_file = "/var/secrets/wireguard_home/indigo_private";
      pubkey = "UjwW2Cd7RbHlS+E7iKq1Igez+325QyxYm7wu3HseCRo=";
    };
    teal = {
      address = "10.0.0.2/24";
      privkey_file = "/var/secrets/wireguard_home/teal_private";
      pubkey = "zJsfvvuFCh5AK2/wl4TZZZlWz2l4SM9fEdWy2mea/0c=";
    };
    dns = "10.0.0.1";
    endpoint = "l3mon4.de:51822";
  };
  wireguard_mullvad_de = {
    indigo = {
      address = "10.71.192.70/32";
      privkey_file = "/var/secrets/wireguard_mullvad/unique_worm.private";
      pubkey = "9ldhvN7r4xGZkGehbsNfYb5tpyTJ5KBb5B3TbxCwklw=";
      local_address = "192.168.178.40/24";
      keepalive = false;
    };
    dns = "10.64.0.1";
    endpoint = "146.70.117.34:51820";
  };
}
