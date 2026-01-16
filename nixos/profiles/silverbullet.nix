{ config, lib, pkgs, machine, data, ... }:

{
  services.silverbullet = {
    enable = true;
    listenPort = data.ports.silverbullet;
  };

  users.users.silverbullet = {
    isSystemUser = true;
    uid = data.ids.silverbullet;
    group = "silverbullet";
  };
  users.groups.silverbullet.gid = data.ids.silverbullet;

  l3mon.services.defs.silverbullet.cfg = data.ports.silverbullet;
}
