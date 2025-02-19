{ config, lib, pkgs, machine, data, ... }:

{
  services.openvpn.servers = {
    unibonn = {config = "config /var/secrets/unibonn.conf";};
  };
  # log in once with root!
  fileSystems."/mnt/wildhorn" = {
    device = "katz@wildhorn.cs.uni-bonn.de:/";
    fsType = "sshfs";
    # only mount on-demand.
    options = [ "noauto" "nodev" "noatime" "allow_other" "ro" "IdentityFile=/var/secrets/id_rsa" "uid=1000" "gid=1000" "x-systemd-requires=openvpn-unibonn.service" ];
  };

  systemd.tmpfiles.rules = [
    "d /mnt/wildhorn 0750 simon simon"
  ];
}
