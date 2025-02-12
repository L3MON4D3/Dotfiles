{ config, lib, pkgs, machine, data, ... }:

{
  wayland.windowManager.sway.extraConfig = ''
    output "BNQ BenQ RL2455 H5G01051SL0" transform 90 resolution 1920x1080@60.000Hz position 2560,0
    output "BNQ BenQ RL2455 H5G01051SL0" subpixel vbgr

    output "Microstep MSI MAG271CQR 0x30303441" transform 0 mode 2560x1440@143.999Hz position 0,0
    output "Microstep MSI MAG271CQR 0x30303441" subpixel rgb

    output "Red Hat, Inc. QEMU Monitor Unknown" transform 0 mode 1280x800@74.994Hz position 0,0

    output "Unknown Unknown Unknown" transform 0 mode 1600x1200@60.000Hz position 0,0
  '';
}
