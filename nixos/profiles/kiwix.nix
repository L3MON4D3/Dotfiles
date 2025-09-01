{ config, lib, pkgs, machine, data, inputs, system, ... }:

let
  zimdir = "/srv/zim";
  zimlib = zimdir + "/lib.xml";
  zimglobs = [
    "archlinux_en*"
    "devdocs_en_css*"
    "devdocs_en_julia*"
    "wikipedia_en_all_maxi*"
    "devdocs_en_bash*"
    "devdocs_en_vulkan*"
    "devdocs_en_python*"
    "kochwiki.org_de*_maxi_*"
    "minecraftwiki_en*"
    "stardewvalleywiki*"
    "100r.co_en_all*"
    "devhints.io_en_all*"
    "devdocs_en_zig*"
    "devdocs_en_nix*"
  ];
in {
  systemd.tmpfiles.settings.kiwixdirs = {
    ${zimdir}.d = lib.mkForce {
      mode = "2770";
      user = "kiwix";
      group = "kiwix";
    };
  };

  users.users.kiwix  = {
    isSystemUser = true;
    uid = data.ids.kiwix;
    group = "kiwix";
  };
  users.groups.kiwix.gid = data.ids.kiwix;
  # allow writing to directory+file (lib.xml) owned by kiwix.
  users.users.qbittorrent.extraGroups = [ "kiwix" ];


  l3mon.qbittorrent = {
    category_savepaths.kiwix-seeder = zimdir;
    finish_scripts = [
      (pkgs.writeShellApplication {
        name = "kiwix-add";
        runtimeInputs = with pkgs; [ kiwix-tools perl gnused ];
        text =
        # bash
        ''
          if [[ "$QB_CATEGORY" == "kiwix-seeder" ]]; then
            if [[ -e ${zimlib} ]]; then
              # remove existing zims for this name from the library.
              # Assumes that one book occupies one line.
              ZIMNAME="$(echo "$QB_NAME" | perl -lpe 's/_\d{4}-\d{2}.zim//g')"
              sed -i 's/.*'"$ZIMNAME"'.*//g' "${zimlib}"
            fi
            kiwix-manage ${zimlib} add "$QB_CONTENT_PATH"
          fi
        '';
      } + "/bin/kiwix-add")
    ];
  };

  systemd = {
    timers."kiwix-seeder" = {
      enable = true;
      wantedBy = ["timers.target"];
      timerConfig = {
        Persistent = true;
        # every day at 4 in the morning.
        OnCalendar = "*-*-* 04:00:00";
        Unit = "kiwix-seeder.service";
      };
    };
    services."kiwix-seeder" = {
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "kiwix";
        Group = "kiwix";
        CacheDirectory = "kiwix-seeder";
      };
      path = [inputs.kiwix-seeder.packages.${system}.default];
      script = ''
        export XDG_CACHE_HOME="$CACHE_DIRECTORY"
        # -C: clear cache, we only check once a day, and when adding a new filename, it's not downloaded if the cached catalog exists.
        # -k: no https.
        # --keep 12w: keep old zimfiles for 12 weeks after addition to qbittorrent.
        # --max-storage: maximum of storage to use. I don't really want to use more than a TB for this.
        kiwix-seeder -C  --keep 12w --max-storage=1000GiB --qbt "http://qbittorrent.internal" -k ${lib.strings.concatMapStrings (s: "--filename '${s}' ") zimglobs}
      '';
    };

    services.kiwix-serve = {
      enable = true;
      requires = [ "network-online.target" ];
      unitConfig.RequiresMountsFor = [ zimdir ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "exec";
        User = "kiwix";
        Group = "kiwix";
        CacheDirectory = "kiwix-serve";
      };
      path = with pkgs; [ kiwix-tools ];
      script = ''
        kiwix-serve -M -l ${zimlib} -p ${toString data.ports.kiwix-serve}
      '';
    };
  };

  services.caddy.extraConfig = ''
    http://kiwix, http://kiwix.internal, http://kiwix.${machine} {
      reverse_proxy http://localhost:${toString data.ports.kiwix-serve}
    }
  '';
}
