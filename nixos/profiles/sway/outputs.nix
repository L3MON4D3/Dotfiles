{ config, lib, pkgs, machine, data, ... }:

let
  dpms_toggle = pkgs.writeShellApplication {
    name = "dpms_toggle";
    runtimeInputs = with pkgs; [
      jq
      sway
    ];
    text = ''
      output=$1
      if swaymsg -t get_outputs | jq -e ".[] | select(.name==\"''${output}\") | .dpms"; then
        echo swaymsg output "''${output}" dpms off
        swaymsg output "''${output}" dpms off
      else
        echo swaymsg output "''${output}" dpms on
        swaymsg output "''${output}" dpms on
      fi
    '';
  };
in {
  wayland.windowManager.sway.extraConfig = ''
    output "BNQ BenQ RL2455 H5G01051SL0" transform 90 resolution 1920x1080@60.000Hz position 2560,0
    output "BNQ BenQ RL2455 H5G01051SL0" subpixel vbgr

    output "Microstep MSI MAG271CQR 0x30303441" transform 0 mode 2560x1440@143.999Hz position 0,0
    output "Microstep MSI MAG271CQR 0x30303441" subpixel rgb

    output "Red Hat, Inc. QEMU Monitor Unknown" transform 0 mode 1280x800@74.994Hz position 0,0

    output "Unknown Unknown Unknown" transform 0 mode 1600x1200@60.000Hz position 0,0

    mode "power" {
      bindsym --no-repeat d output DP-1 dpms toggle; mode "default"
      bindsym --no-repeat h output HDMI-A-1 dpms toggle; mode "default"
    }
  '';
}
