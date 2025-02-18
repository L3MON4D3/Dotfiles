{ config, lib, pkgs, machine, data, ... }:

{
  wayland.windowManager.sway.extraConfig = ''
    # don't limit maximum-size of floating windows.
    floating_maximum_size -1 x -1

    gaps inner 4
    gaps outer 1

    popup_during_fullscreen smart

    bindsym $mod+Return exec "$term 2> /dev/null"

    # kill focused window
    bindsym $mod+q kill

    # Drag floating windows by holding down $mod and left mouse button.
    # Resize them with right mouse button + $mod.
    # Despite the name, also works for non-floating windows.
    # Change normal to inverse to use left mouse button for resizing and right
    # mouse button for dragging.
    floating_modifier $mod normal

    # reload the configuration file
    bindsym $mod+Shift+r reload

    # exit sway (logs you out of your Wayland session)
    bindsym $mod+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'

    #
    # Moving around:
    #

    # Move your focus around
    bindsym $mod+$left focus left
    bindsym $mod+$down focus down
    bindsym $mod+$up focus up
    bindsym $mod+$right focus right
    # or use $mod+[up|down|left|right]
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right

    # _move_ the focused window with the same, but add Shift
    bindsym $mod+Shift+$left move left
    bindsym $mod+Shift+$down move down
    bindsym $mod+Shift+$up move up
    bindsym $mod+Shift+$right move right
    # ditto, with arrow keys
    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Down move down
    bindsym $mod+Shift+Up move up
    bindsym $mod+Shift+Right move right

    #
    # Workspaces:
    #

    # switch to workspace
    bindsym $mod+1 workspace 1
    bindsym $mod+2 workspace 2
    bindsym $mod+3 workspace 3
    bindsym $mod+4 workspace 4
    bindsym $mod+5 workspace 5
    bindsym $mod+6 workspace 6
    bindsym $mod+7 workspace 7
    bindsym $mod+8 workspace 8
    bindsym $mod+9 workspace 9

    # move focused container to workspace
    bindsym $mod+Shift+1 move container to workspace 1
    bindsym $mod+Shift+2 move container to workspace 2
    bindsym $mod+Shift+3 move container to workspace 3
    bindsym $mod+Shift+4 move container to workspace 4
    bindsym $mod+Shift+5 move container to workspace 5
    bindsym $mod+Shift+6 move container to workspace 6
    bindsym $mod+Shift+7 move container to workspace 7
    bindsym $mod+Shift+8 move container to workspace 8
    bindsym $mod+Shift+9 move container to workspace 9

    # Note: workspaces can have any name you want, not just numbers.
    # We just use 1-9 as the default.

    #
    # Layout stuff:
    #

    # You can "split" the current object of your focus with
    # $mod+b or $mod+v, for horizontal and vertical splits
    # respectively.
    bindsym $mod+b splitv
    bindsym $mod+v splith

    # Make the current focus fullscreen
    bindsym $mod+f fullscreen

    # Toggle the current focus between tiling and floating mode
    bindsym $mod+Shift+f floating toggle

    # Swap focus between the tiling area and the floating area
    bindsym $mod+m focus mode_toggle

    # move focus to the parent container
    bindsym $mod+u focus parent

    #
    # Scratchpad:
    #

    # Sway has a "scratchpad", which is a bag of holding for windows.
    # You can send windows there and get them back later.

    # Move the currently focused window to the scratchpad
    bindsym $mod+Shift+Tab move scratchpad

    # Show the next scratchpad window or hide the focused scratchpad window.
    # If there are multiple scratchpad windows, this command cycles through them.
    bindsym $mod+Tab scratchpad show

    bindsym --whole-window $mod+button5 opacity minus .05
    bindsym --whole-window $mod+button4 opacity plus .05

    #
    # Resizing containers:
    #
    mode "resize" {
        # left will shrink the containers width
        # right will grow the containers width
        # up will shrink the containers height
        # down will grow the containers height
        bindsym $left resize shrink width 10px
        bindsym $down resize shrink height 10px
        bindsym $up resize grow height 10px
        bindsym $right resize grow width 10px
    
        # ditto, with arrow keys
        bindsym Left resize shrink width 10px
        bindsym Down resize grow height 10px
        bindsym Up resize shrink height 10px
        bindsym Right resize grow width 10px
    
        # return to default mode
        bindsym Return mode "default"
        bindsym Escape mode "default"
    }
    bindsym $mod+r mode "resize"
    
    #Window-start-setting
    for_window [class="HelloFX"] floating enable
    for_window [app_id="mpv"] floating enable
    for_window [class="controller-JController" title="Open"] floating enable
    for_window [title="worldWp"] floating enable
    for_window [title="Emulator$"] floating enable
    for_window [title="FML early loading progress"] floating enable
    for_window [title="unknown_noise.png"] floating enable
    for_window [title="^glfw$"] floating enable
    for_window [title="Discord Updater"] floating enable
    for_window [title="^Firefox — Sharing Indicator$"] kill
    for_window [title="^floatwindow$"] floating enable
    for_window [title="^Kodi$"] move container output DP-1
    for_window [title="^SkyRenderer$"] floating enable
    for_window [title="^ltsh$"] floating enable
    for_window [title="^zenity$"] floating enable
    for_window [app_id="^com.github.wwmm.easyeffects$"] floating enable
    for_window [class="^gnuplot_qt$"] floating enable
    for_window [app_id="^python3$"] floating enable
    for_window [app_id="^imv$"] floating enable
    for_window [app_id="^alloy$"] floating enable
    for_window [app_id="^eww$"] floating enable
    for_window [title="^Makie$"] floating enable
    for_window [class="^qrenderdoc$"] floating enable
    for_window [instance="^cemu$"] floating enable
    for_window [title="^qutebrowser password fill$"] floating enable
    for_window [class="^yuzu$"] floating enable
    for_window [class="^Ryujinx$"] floating enable
    for_window [app_id="^waybar$"] floating enable
    for_window [class="^exercise.*_.*$"] floating enable
    for_window [title="^Lutris$"] floating enable
    for_window [title="^Lutris$"] floating enable
    for_window [class="Gimp"] floating enable
    for_window [class="ATCG"] floating enable
    for_window [title="^lstopo"] floating enable
    for_window [class="^Vtk$"] floating enable
    for_window [class="^Overcooked2.x86_64$"] move container output DP-1

    mode "apps" {
      bindsym b exec qutebrowser
      bindsym f exec firefox
      bindsym d exec legcord

      bindsym Return mode "default"
      bindsym Escape mode "default"
    }
    bindsym $mod+a mode "apps"

    mode "power" {
      bindsym s mode "default"; exec systemd-run --user systemctl suspend

      bindsym Return mode "default"
      bindsym Escape mode "default"
    }
    bindsym $mod+p mode "power"
  '';
}
