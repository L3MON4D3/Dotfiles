{ config, lib, pkgs, machine, data, ... }:

{
  fileSystems."/mnt/vci-gpu1" = {
    device = "katz@vci-gpu1.informatik.uni-bonn.de:/";
    fsType = "fuse.sshfs";
    options = [ "x-systemd.automount" "user" "idmap=user" "noauto" "nodev" "noatime" "allow_other" "rw" "exec" "IdentityFile=/var/secrets/id_rsa_uni" "uid=1000" "gid=1000" "follow_symlinks" "default_permissions" ];
  };

  fileSystems."/mnt/vci-gpu2" = {
    device = "katz@vci-gpu2.informatik.uni-bonn.de:/";
    fsType = "fuse.sshfs";
    options = [ "x-systemd.automount" "user" "idmap=user" "noauto" "nodev" "noatime" "allow_other" "rw" "exec" "IdentityFile=/var/secrets/id_rsa_uni" "uid=1000" "gid=1000" "follow_symlinks" "default_permissions" ];
  };

  fileSystems."/mnt/gamsburg" = {
    device = "katz@gamsburg.informatik.uni-bonn.de:/";
    fsType = "fuse.sshfs";
    options = [ "x-systemd.automount" "user" "idmap=user" "noauto" "nodev" "noatime" "allow_other" "rw" "exec" "IdentityFile=/var/secrets/id_rsa_uni" "uid=1000" "gid=1000" "follow_symlinks" "default_permissions" ];
  };
}
