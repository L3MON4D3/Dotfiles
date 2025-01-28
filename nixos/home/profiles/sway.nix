{ config, lib, pkgs, machine, data, ... }:

{
  home.packages = with pkgs; [
    foot
  ];

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "foot"; 
      startup = [
        # Launch Firefox on start
        {command = "foot";}
      ];
    };
  };
}
