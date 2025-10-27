{ config, lib, pkgs, machine, data, ... }:

{
  imports = [
    ../../../home/profiles/remote-gpg-agent.nix
  ];
}
