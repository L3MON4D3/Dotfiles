{ networks, name, data, ... }: let
  phys_peerconf = networks.physical.home.peers.${name};
in {
  imports = [
    ../modules/rcservices.nix
    ./interactive.nix
  ];

  deploy = {
    sshConfig = {
      # for initial connection.
      StrictHostKeyChecking = "accept-new";
    };
    host = phys_peerconf.address;
  };
  uci = {
    # luci and rpcd for web-ui.
    retain = [ "luci" "rpcd" ];
    settings = {
      network = {
        interface.loopback = {
          device = "lo";
          ipaddr = "127.0.0.1";
          netmask = "255.0.0.0";
          proto = "static";
        };
      };
      system = {
        system = [{
          timezone = "CET-1";
          zonename = "Europe/Berlin";
          ttylogin = 0;
          log_size = 1024;
          urandom_seed = 0;
          hostname = name;
        }];
        timeserver.ntp = {
          server = [
            "0.openwrt.pool.ntp.org"
            "1.openwrt.pool.ntp.org"
            "2.openwrt.pool.ntp.org"
            "3.openwrt.pool.ntp.org"
          ];
          enable_server = false;
        };
      };
      dropbear.dropbear = [
        {
          Interface = "lan";
          PasswordAuth = false;
        }
      ];
      uhttpd.uhttpd.main = {
        listen_http = [
          "0.0.0.0:80"
          "[::]:80"
        ];
        listen_https = [
          "0.0.0.0:443"
          "[::]:443"
        ];
        redirect_https = true;
        home = "/www";
        lua_prefix = [ "/cgi-bin/luci=/usr/lib/lua/luci/sgi/uhttpd.lua" ];
        cgi_prefix = "/cgi-bin";
        ubus_prefix = "/ubus";
        cert = "/etc/uhttpd.crt";
        key = "/etc/uhttpd.key";
      };
    };
  };
  etc = {
    "dropbear/authorized_keys".text = ''
      ${data.pubkeys.simon-ssh}
    '';
  };
}
