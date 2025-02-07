{ config, lib, pkgs, machine, data, ... }:

{
  imports = [
    ../../profiles/simon.nix
    ../../profiles/localnet.nix
    ./hardware-configuration.nix
  ];

  fileSystems."/srv/misc" = {
    device = "indigo:/misc";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "fsc" ];
  };
  fileSystems."/srv/media" = {
    device = "indigo:/media";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "fsc" ];
  };

  boot.loader.systemd-boot.enable = true;
}
