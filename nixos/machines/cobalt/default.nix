{ config, lib, pkgs, machine, data, self, inputs, patched_wpa_supplicant, ... }:

{
  disabledModules = ["services/networking/wpa_supplicant.nix"];

  imports = [
    "${patched_wpa_supplicant}/wpa_supplicant.nix"

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
      "AndroidAP_jBEfSJ".pskRaw = "ext:psk_phone";
      "Alpakas zu verkaufen - speed".pskRaw = "ext:psk_kim";
    };
    interfaces = ["wlo1"];
    mac_hooks = {
      "home" = {
        mac = "04:b4:fe:ab:a7:6a";
        cmd = ''
          ${pkgs.iproute2}/bin/ip link set dev wg_home2 mtu 1420
          /nix/var/nix/profiles/system/bin/switch-to-configuration switch
        '';
      };
      "alpakas-kim" = {
        mac = "3c:37:12:e0:34:f5";
        cmd = ''
          ${pkgs.iproute2}/bin/ip link set dev wg_home2 mtu 1400
          /nix/var/nix/profiles/system/specialisation/nonhomenet/bin/switch-to-configuration switch
        '';
      };
      default = {
        cmd = ''
          ${pkgs.iproute2}/bin/ip link set dev wg_home2 mtu 1420
          /nix/var/nix/profiles/system/specialisation/nonhomenet/bin/switch-to-configuration switch
        '';
      };
    };
  };

  l3mon.network_namespaces = {
    enable = true;
    network_configs = [
      data.network.wireguard_rec_de
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
    options = [ "x-systemd.automount" "user" "idmap=user" "noauto" "nodev" "noatime" "allow_other" "rw" "exec" "IdentityFile=/var/secrets/id_rsa" "uid=1000" "gid=1000" "follow_symlinks" "default_permissions" ];
  };
  # required for the sshfs_mount above.
  programs.fuse.userAllowOther = true;

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

  specialisation = {
    nonhomenet.configuration = {
      l3mon.peercache = lib.mkForce { pull = false; };
    }; 
  };
  home-manager.sharedModules = [
    ({ config, lib, pkgs, machine, data, ... }: {
      imports = [ ./home ];
    })
  ];
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;
  users.users.simon.extraGroups = [ "wireshark" ];
}
