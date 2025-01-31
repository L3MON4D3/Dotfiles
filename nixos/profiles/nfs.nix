{ config, lib, pkgs, machine, data, ... }:

{
  services.nfs.server.enable = true;
  services.nfs.settings.nfsd = {
    rdma = true;
    vers3 = false;
    vers4 = true;
    "vers4.0" = false;
    "vers4.1" = false;
    "vers4.2" = true;
  };

  # mkBefore not strictly necessary, but seems nice to put the root at the top
  # :)
  services.nfs.server.exports = lib.mkBefore ''
    /srv/nfs          192.168.178.0/24(rw,fsid=0,no_subtree_check)
  '';
}
