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

  services.caddy.extraConfig = ''
    https://silverbullet.internal http://silverbullet.internal {
      tls internal
      reverse_proxy http://127.0.0.1:${toString data.ports.silverbullet}
    }
  '';
}
