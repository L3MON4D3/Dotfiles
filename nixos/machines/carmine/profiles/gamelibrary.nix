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

    pkgs-yuzu.yuzu
    pkgs-suyu.suyu
    pkgs-unstable.ryujinx

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
        pkgs.amdvlk
      ];
    })
    # pkgs.vulkan-tools
    pkgs.prismlauncher
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
          ln -s /home/simon/games games
          ln -s /home/simon/.local/share/lutris lutris
          ln -s /home/simon/.local/state/melonDS melonDS
          ln -s /home/simon/.local/share/PrismLauncher/instances minecraft

          # Important: descend beyond symlinks!!
          restic backup --tag=${tag} --skip-if-unchanged -- \
            ryujinx/bis/user/save \
            suyu/nand/user/save \
            wineprefixes/*/drive_c/users \
            games/*/documents \
            dolphin/* \
            melonDS/* \
            minecraft/* \
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
