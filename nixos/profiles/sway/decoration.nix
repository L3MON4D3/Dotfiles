{ config, lib, pkgs, machine, data, ... }:

{
  wayland.windowManager.sway.extraConfig = let
    fg = data.gruvbox.bg0_h;
    bg = data.gruvbox.regular_aqua;
    focused = data.gruvbox.bright_green;
    unfocused = data.gruvbox.bright_blue;
  in ''
    titlebar_border_thickness 0
    titlebar_padding 3

    default_border none
    default_floating_border normal 1

    font pango:monospace 0.001

    client.focused #${focused} #${focused} #${focused}
    client.unfocused #${unfocused} #${unfocused} #${unfocused}
    client.focused_inactive #${unfocused} #${unfocused} #${unfocused}

    output * bg #${bg} solid_color
  '';
}
