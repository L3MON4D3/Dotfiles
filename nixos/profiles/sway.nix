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
    packages = [
      pkgs.l3mon.iosevka
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
        };
      }
    )
  ];
}
