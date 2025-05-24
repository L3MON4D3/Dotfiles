{ config, lib, pkgs, machine, data, ... }:

{
  imports = [
    ../../profiles/simon.nix
    ../../profiles/mobile-net.nix
    ./hardware-configuration.nix
  ];

  environment.shellAliases = {
    re = ''sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake "/home/simon/projects/dotfiles/nixos#cobalt"'';
  };

  networking.wireless = {
    enable = true;
    secretsFile = "/var/secrets/wifi";
    networks = {
      "FRITZ!Box 5590 RM".pskRaw = "ext:psk_home";
    };
  };

  # fileSystems."/srv/misc" = {
    # device = "indigo:/misc";
    # fsType = "nfs";
    # options = [ "nfsvers=4.2" "rw" "acl" "noauto" "nofail" "x-systemd.automount" "x-systemd.mount-timeout=10" "x-systemd.idle-timeout=5min" ];
  # };
  # fileSystems."/srv/media" = {
    # device = "indigo:/media";
    # fsType = "nfs";
    # options = [ "nfsvers=4.2" "rw" "acl" "noauto" "nofail" "x-systemd.automount" "x-systemd.mount-timeout=10" "x-systemd.idle-timeout=5min" ];
  # };
  # fileSystems."/mnt/paperless" = {
    # device = "indigo:/paperless-consume";
    # fsType = "nfs";
    # options = [ "nfsvers=4.2" "rw" "acl" "noauto" "nofail" "x-systemd.automount" "x-systemd.mount-timeout=10" "x-systemd.idle-timeout=5min" ];
  # };
  # fileSystems."/mnt/data" = {
    # label = "DATA";
    # fsType = "btrfs";
    # options = [ "rw" ];
  # };
  # fileSystems."/mnt/indigo" = {
    # device = "simon@indigo:/";
    # fsType = "fuse.sshfs";
    # # only mount on-demand.
    # options = [ "x-systemd.automount" "user" "idmap=user" "noauto" "nodev" "noatime" "allow_other" "rw" "IdentityFile=/var/secrets/id_rsa" "uid=1000" "gid=1000" "follow_symlinks" "default_permissions" ];
  # };
  # systemd.tmpfiles.rules = [
    # "d /mnt/data 0750 simon simon"
    # "d /mnt/indigo 0750 simon simon"
  # ];

  boot.loader.systemd-boot.enable = true;

  # l3mon.network_namespaces = {
    # enable = true;
    # network_configs = [
      # data.network.wireguard_home2
      # data.network.wireguard_rec_de
    # ];
  # };

  # l3mon.zotero.enable_client = true;

  # home-manager.sharedModules = [
    # ({ config, lib, pkgs, machine, data, ... }: {
      # l3mon.zotero.enable = true;
    # })
  # ];

  # l3mon.restic = {
    # enable = true;
    # repo = {
      # location = "rest:http://restic.internal/simon";
      # passwordFile = "/var/secrets/restic-l3mon";
    # };
  # };

  # hardware.keyboard.qmk.enable = true;

  services.dbus.implementation = "broker";

  # services.caddy.enable = true;
  # services.caddy.enableReload = true;

  # programs.wireshark.enable = true;
  # programs.wireshark.package = pkgs.wireshark;
  # users.users.simon.extraGroups = [ "wireshark" ];

  nix.optimise = {
    automatic = true;
    dates = [ "20:00" ];
  };

  l3mon.peercache = {
    pull = true;
  };
}
