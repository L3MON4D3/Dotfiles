{ config, lib, pkgs, machine, data, ... }:

{
  imports = [
    ../../modules/zotero.nix

    ../../profiles/simon.nix
    ../../profiles/localnet.nix
    ./hardware-configuration.nix

    ../../profiles/sway

    ../../profiles/firefox.nix

    ../../profiles/mxmaster3s.nix
  ];

  environment.shellAliases = {
    re = ''sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake "/home/simon/projects/dotfiles/nixos#carmine"'';
  };

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
  fileSystems."/mnt/paperless" = {
    device = "indigo:/paperless-consume";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "fsc" ];
  };
  fileSystems."/mnt/steamlib" = {
    device = "indigo:/steamlib";
    fsType = "nfs";
    options = [ "nfsvers=4.2" "rw" "acl" "fsc" ];
  };

  boot.loader.systemd-boot.enable = true;

  l3mon.network_namespaces = {
    enable = true;
    network_configs = [
      data.network.wireguard_home2
      data.network.wireguard_mullvad_de2
    ];
  };

  l3mon.zotero.enable_client = true;

  programs.steam.enable = true;

  home-manager.sharedModules = [
    ({ config, lib, pkgs, machine, data, ... }: {
      l3mon.zotero.enable = true;
    })
  ];

  services.openvpn.servers = {
    unibonn = {config = "config /var/secrets/unibonn.conf";};
  };
  # log in once with root!
  fileSystems."/mnt/wildhorn" = {
    device = "katz@wildhorn.cs.uni-bonn.de:/";
    fsType = "sshfs";
    options = ["nodev" "noatime" "allow_other" "ro" "IdentityFile=/var/secrets/id_rsa" "uid=1000" "gid=1000" "x-systemd-requires=openvpn-unibonn.service" ];
  };

  services.dbus.implementation = "broker";
}
