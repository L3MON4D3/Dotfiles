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

}
