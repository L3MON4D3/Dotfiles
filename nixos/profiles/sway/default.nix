{ config, lib, pkgs, pkgs-unstable, nur, machine, data, ... }:

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

  environment.systemPackages = with pkgs; [
    foot.terminfo
  ];

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  home-manager.sharedModules = [
    (
      { config, lib, pkgs, machine, data, ... }:
      
      let
        cursor_theme_name = "capitaine-cursors";
        cursor_size = 6;
        cursor_theme_package = pkgs.capitaine-cursors;
      in {
        imports = [
          ./base.nix
          ./outputs.nix
          ./inputs.nix
          ./decoration.nix
          ./qbittorrent.nix
          ./waybar.nix
        ];

        home.packages = with pkgs; [
          pass
          cursor_theme_package
          adapta-gtk-theme
          adapta-kde-theme
          papirus-icon-theme
        ];

        wayland.windowManager.sway = {
          enable = true;
          systemd = {
            enable = true;
            # check teal:~/.bashrc.d/99-wm.sh
            # variables = [ ];
          };
          wrapperFeatures.gtk = true;
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
          extraConfigEarly = ''
            set $mod Mod4
            set $left h
            set $down j
            set $up k
            set $right l
            set $term footclient

            seat seat0 xcursor_theme "${cursor_theme_name}" ${builtins.toString cursor_size}
          '';
          checkConfig = true;
          config = null;
        };

        l3mon.sway-netns.wg_home2 = {
          enable = true;
          openPrivateWindow = false;
          netnsKey = "h";
          landingPage = "http://git.internal";
          firefoxProfileSettings = {
            id = 1;
            extensions = with nur.repos.rycee.firefox-addons; [
              ublock-origin
              passff
            ];
          };
        };

        l3mon.sway-netns.wg_mullvad_de = {
          enable = true;
          openPrivateWindow = false;
          netnsKey = "d";
          landingPage = "https://mullvad.net/en/check";
          firefoxProfileSettings = {
            id = 2;
            extensions = with nur.repos.rycee.firefox-addons; [
              ublock-origin
              passff
            ];
          };
        };

        xdg.portal = {
          enable = true;
          config.sway = {
            default = [
              "gtk"
              "wlr"
              "gnome"
            ];
            "org.freedesktop.impl.portal.ScreenCast" = "wlr";
            "org.freedesktop.impl.portal.Screenshot" = "wlr";
            "org.freedesktop.impl.portal.FileChooser" = "gtk";
            "org.freedesktop.impl.portal.AppChooser" = "gtk";
            "org.freedesktop.impl.portal.Print" = "gtk";
            "org.freedesktop.impl.portal.Notification" = "gtk";
          };
          extraPortals = with pkgs; [
            xdg-desktop-portal-wlr
            xdg-desktop-portal-gtk
            xdg-desktop-portal-gnome
          ];
        };

        # important!!! needs wrapperFeatures=gtk in sway.
        gtk = {
          enable = true;
          gtk3.extraConfig = {
            gtk-theme-name="Adapta";
            gtk-icon-theme-name="Papirus";
            gtk-font-name="Sans 10";
            gtk-toolbar-style="GTK_TOOLBAR_BOTH";
            gtk-toolbar-icon-size="GTK_ICON_SIZE_LARGE_TOOLBAR";
            gtk-button-images="1";
            gtk-menu-images="1";
            gtk-enable-event-sounds="1";
            gtk-enable-input-feedback-sounds="1";
            gtk-xft-antialias="1";
            gtk-xft-hinting="1";
            gtk-xft-hintstyle="hintfull";
            gtk-xft-rgba="rgb";
          };
        };

        home.pointerCursor = {
          gtk.enable = true;
          x11.enable = true;
          package = cursor_theme_package;
          name = cursor_theme_name;
          size = cursor_size;
        };

        programs.foot = {
          enable = true;
          # up-to-date foot (~1.20.2+) has fix for double-trigger of Enter, Backspace, Tab
          # https://codeberg.org/dnkl/foot/issues/1892
          package = pkgs-unstable.foot;
          server.enable = true;
          settings = {
            main = {
              font =
                "NotoColorEmoji:size=10:antialias=true:autohint=true," +
                "iosevka:size=10:antialias=true:autohint=true," +
                "juliamono:size=10:antialias=true:autohint=true," +
                "codicon:size=10:antialias=true:autohint=true," +
                "Symbols Nerd Font Mono:size=10:antialias=true:autohint=true";
              underline-thickness="1px";
              underline-offset="4px";
            };
            cursor.underline-thickness="2px";
            colors = {
              foreground=data.gruvbox.fg0;
              background=data.gruvbox.bg0_h;

              regular0 = data.gruvbox.bg0_h;
              regular1 = data.gruvbox.regular_red;
              regular2 = data.gruvbox.regular_green;
              regular3 = data.gruvbox.regular_yellow;
              regular4 = data.gruvbox.regular_blue;
              regular5 = data.gruvbox.regular_purple;
              regular6 = data.gruvbox.regular_aqua;
              regular7 = data.gruvbox.regular_fg4;

              bright0 = data.gruvbox.gray;
              bright1 = data.gruvbox.bright_red;
              bright2 = data.gruvbox.bright_green;
              bright3 = data.gruvbox.bright_yellow;
              bright4 = data.gruvbox.bright_blue;
              bright5 = data.gruvbox.bright_purple;
              bright6 = data.gruvbox.bright_aqua;
              bright7 = data.gruvbox.fg0;
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
