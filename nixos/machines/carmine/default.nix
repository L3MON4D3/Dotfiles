{ config, lib, pkgs, machine, data, ... }:

{
  imports = [
    ../../profiles/simon.nix
    ../../profiles/localnet.nix
  ];

  boot.loader.systemd-boot.enable = true;
}
