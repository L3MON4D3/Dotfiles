{ config, lib, pkgs, pkgs-yuzu, pkgs-suyu, pkgs-unstable, machine, data, ... }:

{
  programs.steam.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # battery!?
        experimental = true;

        
        JustWorksRepairing = "always";
        Class = "0x000100";
        FastConnectable = true;
      };
      GATT = {
        ReconnectIntervals="1,1,2,3,5,8,13,21,34,55";
        AutoEnable=true;
      };
    };
  };

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ xpadneo ];
    extraModprobeConfig = ''
      options bluetooth disable_ertm=Y
    '';
  };

  environment.systemPackages = [
    pkgs.blueman

    (pkgs.callPackage ({
      fetchurl,
      appimageTools,
      ...
    }: let
      pname = "yuzu";
      version = "EA-4176";

      src = fetchurl {
        url = "https://archive.org/download/citra-qt-and-yuzu-EA/Linux-Yuzu-EA-4176.AppImage";
        sha256 = "sha256-bUTVL8br2POy5HB1FszlNQNChdRWcwIlG6/RCceXIlg=";
      };

      appimage-contents = appimageTools.extract {
        inherit pname version src;
      };

      desktop-file-name = "org.yuzu_emu.yuzu";
    in
      appimageTools.wrapAppImage {
        inherit pname version;
        src = appimage-contents;
        extraInstallCommands = ''
          install -m 444 -D ${appimage-contents}/${desktop-file-name}.desktop -t $out/share/applications
          cp -r ${appimage-contents}/usr/share/icons $out/share
        '';
      }) {})
    pkgs-suyu.suyu
    pkgs-unstable.ryubing

    pkgs.dolphin-emu
    pkgs.melonDS
    # pkgs.moltengamepad

    pkgs.winetricks
    # pkgs.wineWowPackages.waylandFull
    (pkgs.wineWowPackages.stable.override { waylandSupport = true; })

    # make sure to disable lutris runtime (https://nixos.wiki/wiki/Lutris).
    (pkgs.lutris.override {
      extraLibraries = pkgs: [
        pkgs.vulkan-tools
        pkgs.vulkan-loader
        # pkgs.amdvlk
      ];
    })
    # pkgs.vulkan-tools
    pkgs.prismlauncher

    (pkgs.snes9x-gtk.overrideAttrs (old: {
      propagatedBuildInputs = (if old ? propagatedBuildInputs then old.propagatedBuildInputs else []) ++ [
        # find paths via `nix path-info --derivation $(where snes9x-gtk) --json | jq`
        # /nix/store/0il77pxksdqx9irvzlv123gzmvdv121v-source
        (pkgs.fetchFromGitHub {
          owner = "libretro";
          repo = "glsl-shaders";
          rev = "468f67b6f6788e2719d1dd28dfb2c9b7c3db3cc7";
          hash = "sha256-zdls0sFSd3ciLeWQX7vScE7mdVejdn8Gk1NhGYOif1Y=";
        })
        # /nix/store/rqqxf5r96a0yvzk3lvlkvjbmnjas6j57-source
        (pkgs.fetchFromGitHub {
          owner = "libretro";
          repo = "slang-shaders";
          rev = "d298697e9870d06a86d05db0ead8f1a2a680eb3c";
          hash = "sha256-OckymZJaIhSn5mV4N4spGngPt5YeQG0TBFJ5b1hpdGY=";
        })
      ];
    }))
  ];

  # not the cleanest thing here.
  security.pam.loginLimits = lib.mkOrder (data.ordering.audio-pam-limits - 1) [
    { domain = "simon"; item = "nofile"; type = "-"; value = "524288"; }
  ];

  # for wii-remote.
  services.udev.packages = [ pkgs.dolphin-emu ];

  systemd.tmpfiles.rules = [
    "d /mnt/steamlib 0750 simon simon"
    "d /srv/games 0750 simon simon"
    "z /home/simon/.local/share/PrismLauncher/instances/*/minecraft/saves/*/level.dat 644"
    "z /home/simon/.local/share/PrismLauncher/instances/*/minecraft/saves/*/level.dat_old 644"
    "z /home/simon/.local/share/PrismLauncher/instances/*/minecraft/saves/*/playerdata/* 644"
  ];

  fileSystems."/mnt/steamlib" = {
    device = "indigo:/steamlib";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "fsc" "noauto" "nofail" "x-systemd.automount" "x-systemd.mount-timeout=10" "x-systemd.idle-timeout=5min" ];
  };

  fileSystems."/srv/games" = {
    device = "indigo:/games";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "fsc" "noauto" "nofail" "x-systemd.automount" "x-systemd.mount-timeout=10" "x-systemd.idle-timeout=5min" ];
  };


  l3mon.restic = {
    specs.gamelibrary_simon = let
      savegame_backup = tag: {
        runtimeInputs = [ pkgs.coreutils ];
        text = ''
          TMPDIR="$(mktemp -d)"
          cd "$TMPDIR"
          ln -s /home/simon/.local/share/wineprefixes wineprefixes
          ln -s /home/simon/.config/Ryujinx ryujinx
          ln -s /home/simon/.local/share/dolphin-emu dolphin
          ln -s /home/simon/.local/share/suyu suyu
          ln -s /home/simon/.local/share/yuzu yuzu
          ln -s /home/simon/games games
          ln -s /home/simon/.local/share/lutris lutris
          ln -s /home/simon/.local/state/melonDS melonDS
          ln -s /home/simon/.local/share/PrismLauncher/instances minecraft
          ln -s /home/simon/.local/share/snes9x snes9x-share
          ln -s /home/simon/.config/snes9x snes9x-config

          # Important: descend beyond symlinks!!
          restic backup --tag=${tag} --skip-if-unchanged -- \
            ryujinx/bis/user/save \
            suyu/nand/user/save \
            wineprefixes/*/drive_c/users \
            games/*/documents \
            dolphin/* \
            melonDS/* \
            minecraft/* \
            snes9x-share/* \
            snes9x-config/* \
            lutris/games lutris/lutris.conf lutris/system.yml
          cd /
          rm -rf "$TMPDIR"
        '';
      };
    in {
      backup15min = savegame_backup "savegame-15min";
      backupDaily = savegame_backup "savegame";
      forget = {
        text = ''
          restic forget --tag=savegame-15min --group-by=tag --keep-within=2d
          restic forget --tag=savegame --group-by=tag --keep-last=20 --keep-monthly=12 --keep-yearly=unlimited
        '';
      };
    };
  };

  home-manager.sharedModules = [
    (
      { config, lib, pkgs, machine, data, ... }:
      {
        wayland.windowManager.sway.extraConfig = ''
          assign [class="^steam$"] workspace i1
          assign [class="^steam_app_\d$"] workspace i1
          assign [class="^steam_app_default$"] output DP-3

          for_window [title="^Lutris$"] floating enable
          for_window [app_id="^org.prismlauncher.PrismLauncher$"] floating enable
          for_window [app_id="net.kuribo64.melonDS"] floating enable

          mode "apps" {
            bindsym l exec lutris
            bindsym s exec steam
          }
        '';
      }
    )
  ];
}
