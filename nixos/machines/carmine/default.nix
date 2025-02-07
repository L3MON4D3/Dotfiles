{ config, lib, pkgs, machine, data, ... }:

{
  imports = [
    ../../profiles/simon.nix
    ../../profiles/localnet.nix
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
}
