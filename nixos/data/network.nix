let
  ports = import ./ports.nix;
in
{
  home = {
    address_range = "192.168.178.0/24";
    ssid = "FRITZ!Box 5590 RM";
    peers = {
      carmine = {
        address = "192.168.178.21";
        phys_interface = "enp34s0";
        phys_mac = "00:d8:61:53:a8:63";
        interface = "venp34s0";
        mac = "02:44:3a:85:35:ae";
      };
      indigo = {
        address = "192.168.178.20";
        phys_interface = "enp0s31f6";
        phys_mac = "70:85:c2:01:58:04";
        interface = "venp0s31f6";
        mac = "02:b5:0d:d2:90:a5";
      };
      cobalt = { address = "192.168.178.22"; interface = "wlo1"; };
      carmine_mullvad_de = { address = "192.168.178.41"; mac = "30:e4:58:0a:6e:fc"; };
      indigo_mullvad_de = { address = "192.168.178.40"; mac = "5e:42:b0:71:f7:1b"; };
      merigold = { address = "192.168.178.30"; mac = "02:46:6b:e0:7d:24"; };
      merigold-test = { address = "192.168.178.31"; mac = "02:b6:c0:23:7f:08"; };
      fritzbox = { address = "192.168.178.1"; mac = "0c:72:74:fc:b9:de"; };
      prusamini = { address = "192.168.178.13"; };
      remarkable = { address = "192.168.178.10"; };
    };
  };

  wg_rec_de = {
    address_range = "10.0.1.0/24";
    peers = {
      indigo = { address = "10.0.1.1"; endpoint = "wireguard.l3mon4.de:${toString ports.wireguard_rec_de}"; };
      carmine = { address = "10.0.1.2"; };
      cobalt = { address = "10.0.1.3"; };
    };
  };

  wg_home = {
    address_range = "10.0.0.0/24";
    peers = {
      indigo = { address = "10.0.0.1"; endpoint = "wireguard.l3mon4.de:${toString ports.wireguard_home}"; };
      teal = { address = "10.0.0.2"; };
      canary = { address = "10.0.0.3"; };
      xperia = { address = "10.0.0.4"; };
      remarkable = { address = "10.0.0.5"; };
      carmine = { address = "10.0.0.6"; };
      chromecast = { address = "10.0.0.7"; };
      kim-laptop = { address = "10.0.0.8"; };
      kim-desktop = { address = "10.0.0.9"; };
      cobalt = { address = "10.0.0.10"; };
    };
  };
}
