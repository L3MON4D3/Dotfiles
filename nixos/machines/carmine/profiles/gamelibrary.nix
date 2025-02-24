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
}
