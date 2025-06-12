{ config, lib, pkgs, machine, data, ... }:

let
  primary = "DP-1";
  secondary = "HDMI-A-1";
in {
  wayland.windowManager.sway.extraConfig = ''
    input type:pointer {
      pointer_accel -1
    }

    input 1240:60205:liliums_Lily58 {
        repeat_delay 120
        repeat_rate 100
        xkb_layout "us"
        xkb_variant "altgr-intl"
    }

    # qemu?
    input 1:1:AT_Translated_Set_2_keyboard {
        repeat_delay 120
        repeat_rate 100
        xkb_layout "us"
        xkb_variant "altgr-intl"
    }

    output "${secondary}" transform 90 resolution 1920x1080@60.000Hz position 2560,0
    output "${secondary}" subpixel vbgr

    output "${primary}" transform 0 mode 2560x1440@120.066Hz position 0,0
    output "${primary}" subpixel rgb

    output "Red Hat, Inc. QEMU Monitor Unknown" transform 0 mode 1280x800@74.994Hz position 0,0

    output "Unknown Unknown Unknown" transform 0 mode 1600x1200@60.000Hz position 0,0

    mode "power" {
      bindsym --no-repeat d output "${primary}" dpms toggle; mode "default"
      bindsym --no-repeat h output "${secondary}" dpms toggle; mode "default"

      bindsym --no-repeat b output "${primary}" dpms toggle; output "${secondary}" dpms toggle; mode "default"
    }
  '';
}
