{ config, lib, pkgs, machine, data, ... }:

{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    inter
  ];

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      primary = {
          layer="top";
          output=["eDP-1" "DP-1" "DP-4" "Virtual-1"];
          modules-left=["sway/workspaces" "sway/mode"];
          modules-right=["clock#2" "battery" "clock#1"];
          "clock#1"= {
              format="{:%R}";
          };
          battery= {
              format="{:03}%";
          };
          "clock#2" = {
              "format"="{:%d.%m.%Y}";
          };
          "sway/workspaces" = {
            "alphabetical_sort"= true;
          };
      };
      secondary = {
          layer="top";
          output=["HDMI-A-1" "HDMI-A-2"];
          modules-left=["sway/workspaces" "sway/mode"];
          modules-right=["clock#2" "clock#1"];
          "clock#1"= {
              format="{:%R}";
          };
          "clock#2" = {
              "format"="{:%d.%m.%Y}";
          };
          "sway/workspaces" = {
            "alphabetical_sort"= true;
          };
      };
    };
    style = ''
      * {
          padding: 0px;
          transition-duration: 0s;
          margin-bottom: 0px;
          margin: 0px;
      }

      window#waybar {
          background-color: rgba(1,1,1,0);
          margin: 0;
      }

      #workspaces button {
          margin: 5px 3px 0px 0px;
          background: transparent;
          padding: 0px;
      }

      #workspaces,
      #clock, 
      #battery,
      #mode {
        font-family: 'Inter Display';
        font-size: 11pt;
        font-feature-settings: "tnum";
        padding: 0;
      }

      #workspaces button label {
        padding: 1px 8px 0px 8px;
        margin: 0px;
        color: #ebdbb2;
        border-radius: 5px 5px 5px 5px;
        background-color: #83a598;
      }

      #workspaces {
        margin-left: 5px;
      }

      #workspaces button.visible label,
      #workspaces button.focused label {
        background-color: #458588;
        color: #ebdbb2;
      }

      #mode {
        background-color: #83a598;
          margin: 6px 0px 1px 10px;          
        border-radius: 5px 5px 5px 5px;
        padding: 1px 8px 0px 8px;
          color: #ebdbb2;
        font-weight: normal;
      }

      #clock,
      #battery {
          background-color: #83a598;
          padding: 0px 8px;
          margin: 5px 0px 0px 5px;
        border-radius: 5px 5px 5px 5px;
        color: #ebdbb2;
      }

      #clock.1 {
        margin-right: 5px;
        border-radius: 5px 5px 5px 5px;
      }

      #clock.2 {
        border-radius: 5px 5px 5px 5px;
      }
    '';
  };
}
