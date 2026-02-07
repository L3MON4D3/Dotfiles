{ networks, name, data, ... }: let
  phys_home = networks.physical.home;
  phys_home_peerconf = phys_home.peers.${name};
in {
  imports = [
    (import ../../profiles/common.nix { inherit networks name data; })
  ];
  rcservices.disableServices = [ "dnsmasq" "firewall" ];
  # this device is on the slower side.
  deploy.rebootAllowance = 120;
  uci.retain = [ "luci" "rpcd" ];
  uci = {
    settings = {
      # dhcp.dhcp.lan.ignore = true;
      network = {
        device = [
          {
            name = "br-lan";
            type = "bridge";
            ports = [ "eth0" ];
          }
        ];
        interface = {
          lan = {
            device = "br-lan";
            ipaddr = phys_home_peerconf.address;
            netmask = phys_home.subnet_mask_long;
            proto = "static";
          };
        };
      };
      wireless = {
        wifi-device = {
          radio0_dev = {
            type = "mac80211";
            path = "platform/soc/18000000.wifi";
            band = "2g";
            channel = "1";
            htmode = "HE20";
          };
          radio1_dev = {
            type = "mac80211";
            path = "platform/soc/18000000.wifi+1";
            band = "5g";
            channel = "36";
            htmode = "HE80";
          };
        };
        wifi-iface = {
          radio0 = {
            device = "radio0_dev";
            mode = "ap";
            ssid = name;
            encryption = "psk2";
            key = "pw-wlan123";
            network = "lan";
          };
          radio1 = {
            device = "radio1_dev";
            mode = "ap";
            ssid = name;
            encryption = "psk2";
            key = "pw-wlan123";
            network = "lan";
          };
        };
      };
      system.led = [
        {
          name = "Disable amber";
          sysfs = "amber:status";
          trigger = "none";
        }
        {
          name = "Disable blue";
          sysfs = "blue:wlan-5ghz";
          trigger = "none";
        }
        {
          name = "Disable red";
          sysfs = "red:wlan-2ghz";
          trigger = "none";
        }
        {
          name = "Disable phy0";
          sysfs = "mt76-phy0";
          trigger = "none";
        }
        {
          name = "Disable phy1";
          sysfs = "mt76-phy1";
          trigger = "none";
        }
      ];
    };
  };
}
