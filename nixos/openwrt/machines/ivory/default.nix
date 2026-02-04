{ networks, name, data, ... }: let
  phys_peerconf = networks.physical.home.peers.${name};
  firmware_path = "/lib/firmware/xcpe_8.D.1.C.1.7_8.D.0.E.1.2.bin";
in {
  imports = [
    (import ../../profiles/common.nix { inherit networks name data; })

    ./profiles/firewall.nix
    (import ./profiles/dhcp.nix { inherit networks; })
  ];
  rcservices.disableServices = [ "dnsmasq" ];
  uci = {
    # luci and rpcd for web-ui.
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
            ipaddr = phys_peerconf.address;
            proto = "static";
          };
          wan = {
            proto = "pppoe";
            device = "dsl0.7";
            username = "<dsl-username>";
            password = "<dsl-password>";
            ipv6 = "auto";
          };
          wan6 = {
            device = "@wan";
            proto = "dhcpv6";
          };
        };
      };
      wireless = {
        wifi-device = {
          radio0 = {
            type = "mac80211";
            path = "platform/soc/a000000.wifi";
            band = "2g";
            channel = "auto";
            country = "DE";
            cell_density = 0;
          };
          radio1 = {
            type = "mac80211";
            path = "platform/soc/a800000.wifi";
            band = "5g";
            channel = "auto";
            htmode = "VHT80";
            cell_density = 0;
          };
        };
        wifi-iface = {
          radio0 = {
            mode = "ap";
            ssid = name;
            encryption = "psk2";
            key = "pw-wlan";
            network = "lan";
          };
        };
      };
    };
  };
}
