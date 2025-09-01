{ config, lib, pkgs, pkgs-unstable, machine, data, ... }:

let
  machine_lan_address = data.network.lan.peers.${machine}.address;
in {
  users.users.karakeep.uid = data.ids.karakeep;
  users.groups.karakeep.gid = data.ids.karakeep;

  services.karakeep = {
    enable = true;
    package = pkgs-unstable.karakeep.overrideAttrs (old: {
      # from https://github.com/NixOS/nixpkgs/pull/416531
      postInstall = ''
        # provide a environment variable to override the cache directory
        # https://github.com/vercel/next.js/discussions/58864
        # solution copied from nextjs-ollama-llm-ui
        substituteInPlace $out/lib/karakeep/apps/web/.next/standalone/node_modules/next/dist/server/image-optimizer.js \
          --replace '_path.join)(distDir,' '_path.join)(process.env["NEXT_CACHE_DIR"] || distDir,'
      '';
    });
    # environmentFile = "/var/secrets/karakeep-envfile";
    extraEnvironment = {
      PORT = toString data.ports.karakeep;
      DISABLE_SIGNUPS = "false";
      DISABLE_NEW_RELEASE_CHECK = "true";
      CRAWLER_VIDEO_DOWNLOAD = "true";
      # 100 hrs.
      CRAWLER_VIDEO_DOWNLOAD_TIMEOUT_SEC = "360000";
      CRAWLER_VIDEO_DOWNLOAD_MAX_SIZE = "-1";

      # from https://github.com/NixOS/nixpkgs/pull/416531
      # uses systemd unit CacheDirectory instead of in nix store
      NEXT_CACHE_DIR = "$CACHE_DIRECTORY";
    };
  };

  services.meilisearch = {
    package = pkgs-unstable.meilisearch;
    enable = true;
    listenPort = data.ports.meilisearch;
  };

  services.caddy.extraConfig = ''
    http://kk, http://kk.internal, http://kk.${machine} {
      reverse_proxy http://${machine_lan_address}:${toString data.ports.karakeep}
    }
  '';
}
