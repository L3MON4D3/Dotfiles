{ config, lib, pkgs, machine, data, ... }:

{
  imports = [
    ../../modules/zotero.nix
    ../../modules/blocky.nix

    ../../profiles/simon.nix
    ../../profiles/localnet.nix
    ./hardware-configuration.nix

    ../../profiles/sway

    ../../profiles/firefox.nix

    ../../profiles/mxmaster3s.nix
    ../../profiles/unibonn.nix

    ./profiles/gamelibrary.nix
    ./profiles/cachefilesd.nix
    ./profiles/remarkable.nix
    ./profiles/ollama.nix
    ./profiles/cardinal.nix
    # ./profiles/mympd.nix
  ];

  environment.shellAliases = {
    re = ''sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake "/home/simon/projects/dotfiles/nixos#carmine"'';
  };

  fileSystems."/srv/misc" = {
    device = "indigo:/misc";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "noauto" "nofail" "x-systemd.automount" "x-systemd.mount-timeout=10" "x-systemd.idle-timeout=5min" ];
  };
  fileSystems."/srv/media" = {
    device = "indigo:/media";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "noauto" "nofail" "x-systemd.automount" "x-systemd.mount-timeout=10" "x-systemd.idle-timeout=5min" ];
  };
  fileSystems."/mnt/paperless" = {
    device = "indigo:/paperless-consume";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "noauto" "nofail" "x-systemd.automount" "x-systemd.mount-timeout=10" "x-systemd.idle-timeout=5min" ];
  };
  fileSystems."/mnt/data" = {
    label = "DATA";
    fsType = "btrfs";
    options = [ "rw" ];
  };
  fileSystems."/mnt/indigo" = {
    device = "simon@indigo:/";
    fsType = "fuse.sshfs";
    # only mount on-demand.
    options = [ "x-systemd.automount" "user" "idmap=user" "noauto" "nodev" "noatime" "allow_other" "rw" "exec" "IdentityFile=/var/secrets/id_rsa" "uid=1000" "gid=1000" "follow_symlinks" "default_permissions" ];
  };
  systemd.tmpfiles.rules = [
    "d /mnt/data 0750 simon simon"
    "d /mnt/indigo 0755 simon simon"
  ];

  # required for the sshfs_mount above.
  programs.fuse.userAllowOther = true;

  boot.loader.systemd-boot.enable = true;

  l3mon.network_namespaces = {
    enable = true;
    network_configs = [
      data.network.wireguard_home2
      data.network.wireguard_rec_de
    ];
  };

  networking.nftables.enable = true;
  networking.firewall.enable = lib.mkForce true;
  # mpd
  networking.firewall.allowedTCPPorts = [6600];

  l3mon.zotero.enable_client = true;

  home-manager.sharedModules = [
    ({ config, lib, pkgs, machine, data, ... }: {
      imports = [ ./home ];

      l3mon.zotero.enable = true;
    })
  ];

  l3mon.restic = {
    enable = true;
    repo = {
      location = "rest:http://restic.internal/simon";
      passwordFile = "/var/secrets/restic-l3mon";
    };
  };

  hardware.keyboard.qmk.enable = true;

  services.dbus.implementation = "broker";

  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;
  users.users.simon.extraGroups = [ "wireshark" ];

  nix.optimise = {
    automatic = true;
    dates = [ "20:00" ];
  };

  l3mon.peercache = {
    pull = true;
    push = true;
  };

  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  programs.nix-ld = {
    enable = true; 
    # libraries = with pkgs; [ zstd coreutils gtk3 pango cairo atkmm ];
  };
}
