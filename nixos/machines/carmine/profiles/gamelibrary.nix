{ config, lib, pkgs, pkgs-yuzu, pkgs-unstable, machine, data, ... }:

{
  programs.steam.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  environment.systemPackages = [
    pkgs-yuzu.yuzu
    pkgs-unstable.suyu
    pkgs-unstable.ryujinx

    pkgs.dolphin-emu
    # pkgs.moltengamepad

    pkgs.winetricks
    # pkgs.wineWowPackages.waylandFull
    (pkgs.wineWowPackages.stable.override { waylandSupport = true; })

    # make sure to disable lutris runtime (https://nixos.wiki/wiki/Lutris).
    (pkgs.lutris.override {
      extraLibraries = pkgs: [
        pkgs-unstable.suyu
        pkgs.vulkan-tools
        pkgs.vulkan-loader
        pkgs.amdvlk
      ];
    })
    # pkgs.vulkan-tools
  ];

  # for wii-remote.
  services.udev.packages = [ pkgs.dolphin-emu ];

  systemd.tmpfiles.rules = [
    "d /mnt/steamlib 0750 simon simon"
    "d /srv/games 0750 simon simon"
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

          restic backup --tag=${tag} --skip-if-unchanged -- \
            ryujinx/bis/user/save \
            suyu/nand/user/save \
            wineprefixes/*/drive_c/users \
            games/*/documents \
            dolphin/* \
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
}
