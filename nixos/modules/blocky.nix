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
          "https://dns0.eu/dns-query"
          "https://dns.sb/dns-query"
        ]
      );
      bootstrapDns = [
        # dns.sb
        { upstream = "185.222.222.222"; }
        # google
        { upstream = "8.8.8.8"; }
        # cloudflare
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
        # TODO: right now DNS works well because I declare all network-wide
        # services on the machine that also serves dns, but to make this work
        # properly, I'd have to evaluate the config of other machines (carmine)
        # as well, and if they have some network-wide services, then handle
        # these entries as well.
        # Similar to peercache, but one issue: here we only get the
        # network-spec to identify the services, and I can't directly go from
        # the network spec of one machine to that of another.
        # So, I'd need some search that gives me the keys
        # (virtual->home->network) from just the network, ie. some D/BFS style
        # search with a limited depth (or just BFS, i'll find the network
        # before going too deep).
        mapping = lib.concatMapAttrs (
          peername: peerconf:
          {
            ${peername} = peerconf.address;
            "${peername}.internal" = peerconf.address;
          }
          // (
              builtins.listToAttrs (
                (lib.concatMap (service_name: [
                  {
                    name = "${service_name}.${peerconf.machine_id}.internal";
                    value = peerconf.address;
                  }
                ]) peerconf.machine_services)
                ++
                (lib.concatMap (service_name: [
                  {
                    name = "${service_name}.internal";
                    value = peerconf.address;
                  }
                ]) peerconf.network_services)
              )
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
  config.lib.l3mon.blocky = {
    mkService = mkBlockyService;
    mkConfig = mkConfigFile;
  };
}
