{ config, lib, pkgs, machine, data, ... }:

{
  wayland.windowManager.sway.extraConfig = ''
    mode "apps" {
      bindsym u exec ${pkgs.mattermost-desktop}/bin/mattermost-desktop
    }
  '';
}
