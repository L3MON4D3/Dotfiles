{ config, lib, l3lib, pkgs, machine, data, ... }:

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

  systemd.user.services.sway_top_bar = let
    sway_top_bar = l3lib.writeLuajit "/bin/sway_top_bar" { libraries = [ pkgs.l3mon.k-sway ]; } ''
      local Sway = require("sway")
      local sway = Sway.connect()

      for event in sway:subscribe({"window"}, 0) do
          -- have to apply border to new windows, and windows whose floating is toggled.
          if event.change == "floating" or event.change == "new" then
              -- os.execute("${pkgs.coreutils}/bin/sleep .001")
              local command = event.container.type == "floating_con" and
                  "border pixel 1, border normal" or "border pixel 0, border normal"
              sway:msg(("[con_id=%s] %s"):format(event.container.id, command))
          end
      end
    '';
  in {
    Unit = {
      Description = "Adjust top-bar for floating/tiling windows.";
      PartOf = [ "sway-session.target" ];
      After = [ "sway-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      ExecStart = "${sway_top_bar}/bin/sway_top_bar";
    };
    Install = {
      WantedBy = [ "sway-session.target" ];
    };
  };
}
