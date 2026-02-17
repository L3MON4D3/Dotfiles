{ networks, name, data, config, ... }: let
  phys_home = networks.physical.home;
  phys_home_peerconf = phys_home.peers.${name};
  firmware_path = "/lib/firmware/xcpe_8.D.1.C.1.7_8.D.0.E.1.2.bin";
in {
  imports = [
    ./profiles/firewall.nix
    ./profiles/dhcp.nix
  ];
  rcservices.disableServices = [ "dnsmasq" ];
  users.root.hashedPasswordSecret = config.lib.secrets.secretmap.ivory_pw_hashed.id;
  # this device is on the slower side.
  deploy.rebootAllowance = 120;
  uci = {
    settings = {
      network = {
        device = [
          {
            name = "br-lan";
            type = "bridge";
            ports = [ "lan1" "lan2" "lan3" "lan4" ];
          }
          {
            name = "dsl0";
            # Is this arbitrary or determined by the hardware?
            macaddr = "98:9B:CB:7A:00:2B";
          }
        ];
        atm-bridge.atm = {
          vpi = 1;
          vci = 32;
          encaps = "llc";
          payload = "bridged";
          nameprefix = "dsl";
        };
        dsl.dsl = {
          annex = "j";
          ds_snr_offset = "0";
          xfer_mode = "ptm";
          firmware = firmware_path;
        };
        interface = {
          lan = {
            device = "br-lan";
            ipaddr = phys_home_peerconf.address;
            netmask = phys_home.subnet_mask_long;
            proto = "static";
          };
          wan = {
            proto = "pppoe";
            device = "dsl0.7";
            username._secret = config.lib.secrets.secretmap.dsl_user.id;
            password._secret = config.lib.secrets.secretmap.dsl_pw.id;
            ipv6 = "auto";
          };
          wan6 = {
            device = "@wan";
            proto = "dhcpv6";
          };
        };
        globals.globals.ula_prefix = "fd5f:e8cc:822c::/48";
      };
      # wireless = {
        # wifi-device = {
          # radio0_dev = {
            # type = "mac80211";
            # path = "platform/soc/a000000.wifi";
            # band = "2g";
            # channel = "auto";
            # country = "DE";
            # cell_density = 0;
          # };
          # radio1_dev = {
            # type = "mac80211";
            # path = "platform/soc/a800000.wifi";
            # band = "5g";
            # channel = "auto";
            # htmode = "VHT80";
            # cell_density = 0;
          # };
        # };
        # wifi-iface = {
          # radio0 = {
            # device = "radio0_dev";
            # mode = "ap";
            # ssid = name;
            # encryption = "psk2";
            # key = "pw-wlan123";
            # network = "lan";
          # };
          # radio1 = {
            # device = "radio1_dev";
            # mode = "ap";
            # ssid = name;
            # encryption = "psk2";
            # key = "pw-wlan123";
            # network = "lan";
          # };
        # };
      # };
    };
  };
}
