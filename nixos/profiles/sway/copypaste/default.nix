{ config, l3lib, lib, pkgs, machine, data, ... }:

let
sway-copypaste = l3lib.writeLuajit "/bin/sway-copypaste" {
  libraries = [
    pkgs.l3mon.k-sway
  ]; } (builtins.readFile ./sway-copypaste.lua);
in {
  wayland.windowManager.sway.extraConfig = ''
    bindsym $mod+Shift+C exec ${sway-copypaste}/bin/sway-copypaste cut
    bindsym $mod+Shift+V exec ${sway-copypaste}/bin/sway-copypaste paste
  '';
}
