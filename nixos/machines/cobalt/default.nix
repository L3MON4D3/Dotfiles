{ config, lib, pkgs, machine, data, ... }:

{
  imports = [
    ../../profiles/simon.nix
    ../../profiles/sway
    ../../profiles/mobile-net.nix
    ../../profiles/firefox.nix
    ../../profiles/mxmaster3s.nix

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

  l3mon.network_namespaces = {
    enable = true;
    network_configs = [
      data.network.wireguard_mv_cb_de
    ];
  };

  fileSystems."/srv/misc" = {
    device = "indigo:/misc";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "noauto" "nofail" "soft" "timeo=5" "x-systemd.automount" "x-systemd.mount-timeout=5" "x-systemd.idle-timeout=5min" ];
  };
  fileSystems."/srv/media" = {
    device = "indigo:/media";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "noauto" "nofail" "soft" "timeo=5" "x-systemd.automount" "x-systemd.mount-timeout=5" "x-systemd.idle-timeout=5min" ];
  };
  fileSystems."/mnt/paperless" = {
    device = "indigo:/paperless-consume";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "noauto" "nofail" "soft" "timeo=5" "x-systemd.automount" "x-systemd.mount-timeout=5" "x-systemd.idle-timeout=5min" ];
  };
  # fileSystems."/mnt/data" = {
    # label = "DATA";
    # fsType = "btrfs";
    # options = [ "rw" ];
  # };
  fileSystems."/mnt/indigo" = {
    device = "simon@indigo:/";
    fsType = "fuse.sshfs";
    # only mount on-demand.
    options = [ "x-systemd.automount" "user" "idmap=user" "noauto" "nodev" "noatime" "allow_other" "rw" "IdentityFile=/var/secrets/id_rsa" "uid=1000" "gid=1000" "follow_symlinks" "default_permissions" ];
  };
  systemd.tmpfiles.rules = [
    "d /mnt/indigo 0755 simon simon"
  ];

  boot.loader.systemd-boot.enable = true;

  services.dbus.implementation = "broker";

  nix.optimise = {
    automatic = true;
    dates = [ "20:00" ];
  };

  l3mon.peercache = {
    pull = true;
  };

  home-manager.sharedModules = [
    ({ config, lib, pkgs, machine, data, ... }: {
      imports = [ ./home ];
    })
  ];
}
