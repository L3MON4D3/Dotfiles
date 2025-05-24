{ config, lib, l3lib, pkgs, machine, data, ... }:

with lib;
let
  sway_cfg = config.l3mon.sway;
  cfg = config.l3mon.sway.workrooms;
in {
  options.l3mon.sway.workrooms = {
    enable = mkEnableOption "Enable workrooms";
  };
  config = mkIf cfg.enable (let
    outputs = sway_cfg.outputs;
  in {
    programs.waybar.package = pkgs.waybar.overrideAttrs (final: previous: {
      patches = previous.patches ++ [
        ./waybar-workrooms.patch
      ];
      hyprlandSupport = false;
    });
    
    wayland.windowManager.sway.extraConfig = let
      # simple writeTextFile does not work :/
      output_conf = pkgs.luajit.pkgs.buildLuaPackage {
        pname = "output_conf";
        version = "1.0";
        src = pkgs.writeText "output_conf" ''
          return {
            ${lib.strings.concatLines
              (lib.imap1 (i: v: ''["${v}"] = ${toString i},'') outputs)
            }
          }
        '';
        phases = ["installPhase"];
        installPhase = ''
          mkdir -p $out/share/lua/5.1/
          cp $src $out/share/lua/5.1/output_conf.lua
        '';
      };
      sway-workrooms = l3lib.writeLuajit "/bin/sway-workrooms" {
        libraries = [
          pkgs.l3mon.k-sway
          pkgs.luajitPackages.cjson
          output_conf
        ]; } (builtins.readFile ./sway-workrooms.lua);
    in lib.mkAfter (''
      set $workroom h
      bindsym --no-warn $mod+Alt+h exec ${sway-workrooms}/bin/sway-workrooms h
      bindsym --no-warn $mod+Alt+j exec ${sway-workrooms}/bin/sway-workrooms j
      bindsym --no-warn $mod+Alt+k exec ${sway-workrooms}/bin/sway-workrooms k
      bindsym --no-warn $mod+Alt+l exec ${sway-workrooms}/bin/sway-workrooms l
      bindsym --no-warn $mod+Alt+y exec ${sway-workrooms}/bin/sway-workrooms y
      bindsym --no-warn $mod+Alt+u exec ${sway-workrooms}/bin/sway-workrooms u
      bindsym --no-warn $mod+Alt+i exec ${sway-workrooms}/bin/sway-workrooms i
      bindsym --no-warn $mod+Alt+o exec ${sway-workrooms}/bin/sway-workrooms o
      
      # switch to workspace
      bindsym --no-warn $mod+1 workspace $$workroom1
      bindsym --no-warn $mod+2 workspace $$workroom2
      bindsym --no-warn $mod+3 workspace $$workroom3
      bindsym --no-warn $mod+4 workspace $$workroom4
      bindsym --no-warn $mod+5 workspace $$workroom5
      bindsym --no-warn $mod+6 workspace $$workroom6
      bindsym --no-warn $mod+7 workspace $$workroom7
      bindsym --no-warn $mod+8 workspace $$workroom8
      bindsym --no-warn $mod+9 workspace $$workroom9
      #bindsym $mod+0 workspace 10
      
      # move focused container to workspace
      bindsym --no-warn $mod+Shift+1 move container to workspace $$workroom1
      bindsym --no-warn $mod+Shift+2 move container to workspace $$workroom2
      bindsym --no-warn $mod+Shift+3 move container to workspace $$workroom3
      bindsym --no-warn $mod+Shift+4 move container to workspace $$workroom4
      bindsym --no-warn $mod+Shift+5 move container to workspace $$workroom5
      bindsym --no-warn $mod+Shift+6 move container to workspace $$workroom6
      bindsym --no-warn $mod+Shift+7 move container to workspace $$workroom7
      bindsym --no-warn $mod+Shift+8 move container to workspace $$workroom8
      bindsym --no-warn $mod+Shift+9 move container to workspace $$workroom9
      
      # set default workspace.
      # workspace h1 output "Unknown Unknown Unknown"
      # workspace h2 output HDMI-A-1
      
      # show first two workspaces?
      # workspace h2
      # workspace h1
    '' +
    (lib.strings.concatLines (
      lib.imap1 (i: v: ''workspace h${toString i} output ${v}'') outputs
    )));
  });
}
