{ config, lib, pkgs, machine, data, ... }:

{
  wayland.windowManager.sway.extraConfig = ''
    input 1133:50504:Logitech_USB_Receiver_Mouse {
      pointer_accel -1
    }

    input 1240:60205:liliums_Lily58_Mouse {
      pointer_accel 1
      scroll_factor 0.06
    }

    input 1240:60205:liliums_Lily58 {
        repeat_delay 120
        repeat_rate 100
        xkb_layout "us"
        xkb_variant "altgr-intl"
    }

    input 1:1:AT_Translated_Set_2_keyboard {
        repeat_delay 120
        repeat_rate 100
        xkb_layout "de"
        # xkb_variant "altgr-intl"
    }

    output "AU Optronics 0x38ED Unknown" transform 0 mode 1920x1080@60.096Hz position 0,0

    mode "power" {
      bindsym --no-repeat d output DP-1 dpms toggle; mode "default"
      bindsym --no-repeat h output HDMI-A-1 dpms toggle; mode "default"

      bindsym --no-repeat b output DP-1 dpms toggle; output HDMI-A-1 dpms toggle; mode "default"
    }
  '';
}
