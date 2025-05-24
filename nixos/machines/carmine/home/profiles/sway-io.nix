{ config, lib, pkgs, machine, data, ... }:

{
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

    output "BNQ BenQ RL2455 H5G01051SL0" transform 90 resolution 1920x1080@60.000Hz position 2560,0
    output "BNQ BenQ RL2455 H5G01051SL0" subpixel vbgr

    output "Microstep MSI MAG271CQR 0x30303441" transform 0 mode 2560x1440@143.999Hz position 0,0
    output "Microstep MSI MAG271CQR 0x30303441" subpixel rgb

    output "Red Hat, Inc. QEMU Monitor Unknown" transform 0 mode 1280x800@74.994Hz position 0,0

    output "Unknown Unknown Unknown" transform 0 mode 1600x1200@60.000Hz position 0,0

    mode "power" {
      bindsym --no-repeat d output DP-1 dpms toggle; mode "default"
      bindsym --no-repeat h output HDMI-A-1 dpms toggle; mode "default"

      bindsym --no-repeat b output DP-1 dpms toggle; output HDMI-A-1 dpms toggle; mode "default"
    }
  '';
}
