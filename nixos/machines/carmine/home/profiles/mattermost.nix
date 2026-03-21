{ config, lib, pkgs, pkgs-unstable, machine, data, ... }:

let
  mattermost = pkgs-unstable.mattermost-desktop;
in {
  home.packages = [
    mattermost
  ];

  wayland.windowManager.sway.extraConfig = ''
    mode "apps" {
      bindsym u exec ${mattermost}/bin/mattermost-desktop
    }
  '';
}
