# This file keeps all users in sync across machines!
# While sometimes users will be created although not necessary, this makes using
# nfs easier :D
{ config, lib, pkgs, machine, data, ... }:
{
  users.users.simon = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user and provide user-group.
    packages = with pkgs; [
      tree
    ];
    uid = 1000;
  };

  users.users.simon.openssh.authorizedKeys.keys = [
    data.pubkey
  ];

  # for correct permissions on files from nfs/existing data.
  users.groups.nfs.gid = 1000;
}
