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
  '';
}
