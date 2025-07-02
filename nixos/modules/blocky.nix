{
  config,
  lib,
  pkgs,
  machine,
  data,
  ...
}:

with lib;
let
  format = pkgs.formats.yaml { };

  mkConfigFile = spec: (
    format.generate "config.yaml" {
      ports.dns = spec.ports;
      upstreams.groups.default = (
      if spec ? upstream then
        spec.upstream
      else
        [
          "https://one.one.one.one/dns-query" # Using Cloudflare's DNS over HTTPS server for resolving queries.
          "https://dns0.eu"
        ]
      );
      bootstrapDns = [
        { upstream = "8.8.8.8"; }
        { upstream = "1.1.1.1"; }
        { upstream = "1.0.0.1"; }
      ];
      blocking = if spec.block then
        {
          denylists = {
            ads = [ "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" ];
            porn = [ "https://blocklistproject.github.io/Lists/porn.txt" ];
          };
          clientGroupsBlock = {
            default = [
              "ads"
              # "porn"
            ];
          };
          loading.downloads.timeout = "30s";
        }
      else
        { }
      ;
      # for some reason importing the list with ipv6 fails..?
      connectIPVersion = "v4";
      customDNS = {
        customTTL = "1h";
        # don't forward queries for these names, even if the query-type (eg.
        # AAAA) is not defined.
        filterUnmappedTypes = true;
        mapping = lib.concatMapAttrs (
          peername: peerconf:
          {
            ${peername} = peerconf.address;
            "${peername}.internal" = peerconf.address;
          }
          // (
            if peerconf ? services then
              (builtins.listToAttrs (
                lib.concatMap (service_name: [
                  {
                    name = "${service_name}.${peerconf.machine_id}";
                    value = peerconf.address;
                  }
                  {
                    name = service_name;
                    value = peerconf.address;
                  }
                  {
                    name = "${service_name}.internal";
                    value = peerconf.address;
                  }
                ]) peerconf.services
              ))
            else
              { }
          )
        ) spec.network.peers;
      };
    }
  );

  mkBlockyService = spec: {
    description = "A DNS proxy and ad-blocker for the local network";
    wantedBy = [ "multi-user.target" ];
    requires = [
      "network-online.target"
      "systemd-networkd-wait-online.service"
    ];
    after = [
      "network-online.target"
      "systemd-networkd-wait-online.service"
    ];

    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${pkgs.blocky}/bin/blocky --config ${spec.conf}";
      Restart = "on-failure";

      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
    };
  };
in
{
  options = {
    l3mon.blocky.mkService = mkOption {
      type = types.anything;
      description = lib.mdDoc ''
        Call with a attrset with single key `conf` to produce a systemd-service
        for starting blocky with the provided conf.
      '';
      readOnly = true;
      default = mkBlockyService;
    };
    l3mon.blocky.mkConfig = mkOption {
      type = types.anything;
      description = lib.mdDoc ''
        Generates a yaml-config for blocky.
      '';
      readOnly = true;
      default = mkConfigFile;
    };
  };
}
