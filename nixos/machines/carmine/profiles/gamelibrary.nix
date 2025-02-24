{ config, lib, pkgs, pkgs-yuzu, pkgs-unstable, machine, data, ... }:

{
  programs.steam.enable = true;

  environment.systemPackages = [
    pkgs-yuzu.yuzu
    pkgs-unstable.suyu
    pkgs.ryujinx

    pkgs.winetricks
    pkgs.wineWowPackages.waylandFull

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

  systemd.tmpfiles.rules = [
    "d /mnt/steamlib 0750 simon simon"
    "d /srv/games 0750 simon simon"
  ];

  fileSystems."/mnt/steamlib" = {
    device = "indigo:/steamlib";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "fsc" ];
  };

  fileSystems."/srv/games" = {
    device = "indigo:/games";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "fsc" ];
  };
}
