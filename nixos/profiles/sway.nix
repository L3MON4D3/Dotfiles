{ config, lib, pkgs, machine, data, ... }:

{
  # system-level options.
  security.polkit.enable = true;
  security.rtkit.enable = true;
  
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  services.gnome.gnome-keyring.enable = true;
  hardware.graphics.enable = true;

  # fonts.
  fonts = {
    packages = with pkgs; [
      l3mon.iosevka
      julia-mono
      nerdfonts
    ];
    enableDefaultPackages = true;
  };

  home-manager.sharedModules = [
    (
      { config, lib, pkgs, machine, data, ... }:
      
      {
        wayland.windowManager.sway = {
          enable = true;
          systemd = {
            enable = true;
            # check teal:~/.bashrc.d/99-wm.sh
            # variables = [ ];
          };
          extraSessionCommands = ''
            export SDL_VIDEODRIVER=wayland
            export _JAVA_AWT_WM_NONREPARENTING=1
            export MOZ_ENABLE_WAYLAND=1
            export QT_QPA_PLATFORM=wayland
            export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
          '' +
          "export _JAVA_OPTIONS='" +
            "-Dawt.useSystemAAFontSettings=on " +
            "-Dswing.aatext=true " +
            "-Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel" +
            "'";
          config = rec {
            modifier = "Mod4";
            terminal = "footclient"; 
          };
        };

        programs.foot = {
          enable = true;
          server.enable = true;
          settings = {
            main = {
              font =
                "NotoColorEmoji:size=10:antialias=true:autohint=true," +
                "iosevka:size=10:antialias=true:autohint=true," +
                "juliamono:size=10:antialias=true:autohint=true," +
                "codicon:size=10:antialias=true:autohint=true," +
                "Symbols Nerd Font Mono:size=10:antialias=true:autohint=true";
              term = "foot-extra";
              underline-thickness="1px";
              underline-offset="4px";
            };
            cursor.underline-thickness="2px";
            colors = {
              foreground="fbf1c7";
              background="1d2021";

              regular0="1d2021";
              # adjust red
              regular1="d75151";
              regular2="98971a";
              regular3="d79921";
              regular4="458588";
              regular5="b16286";
              regular6="689d6a";
              regular7="a89984";

              bright0="928374";
              bright1="fb4934";
              bright2="b8bb26";
              bright3="fabd2f";
              bright4="83a598";
              bright5="d3869b";
              bright6="8ec07c";
              bright7="fbf1c7";
            };
            tweak = {
              box-drawing-base-thickness = 0.06;
              font-monospace-warn = "no";
            };
          };
        };
      }
    )
  ];
}
