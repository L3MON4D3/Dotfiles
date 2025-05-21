{ config, lib, pkgs, pkgs-unstable, nur, machine, data, ... }:

let
  sway_float = pkgs.writeShellApplication {
    name = "sway_float";
    runtimeInputs = with pkgs; [
      sway
      jq
      # xargs
      findutils
      # tail
      coreutils
      # kill
      util-linux
    ];
    text = ''
      "$@" &
      pid=$!

      echo "$PATH"
      swaymsg -t subscribe -m '[ "window" ]' \
        | jq --unbuffered --argjson pid "$pid" '.container | select(.pid == $pid) | .id' \
        | xargs -I '@' -- swaymsg '[ con_id=@ ] floating enable' &

      subscription=$!

      echo Going into wait state

      # Wait for our process to close
      tail --pid=$pid -f /dev/null

      echo Killing subscription
      kill $subscription
    '';
  };
  
  nerdfonts_symbols_only = (pkgs.nerdfonts.override (old: {fonts = [ "NerdFontsSymbolsOnly" ];}));
  gen_scaled_font = pkgs.writers.writePython3Bin "gen_scaled_font" {
    libraries = with pkgs; [ python312Packages.fontforge ];
  } ''
    import fontforge
    import psMat

    symbols = fontforge.open("${nerdfonts_symbols_only}/share/fonts/truetype/NerdFonts/SymbolsNerdFontMono-Regular.ttf")  # noqa: E501. The path is too long.

    scaled_f = fontforge.font()
    scaled_f.version = symbols.version
    scaled_f.weight = symbols.weight
    scaled_f.familyname = "Symbols Scaled"
    scaled_f.fontname = "SymbolsScaled-Mono"
    scaled_f.fullname = "Symbols Scaled Mono"
    scaled_f.em = symbols.em
    scaled_f.design_size = symbols.design_size
    scaled_f.ascent = symbols.ascent
    scaled_f.descent = symbols.descent

    # c_x,y found manually, valid for circles.
    c_x = 1023
    c_y = 482+101
    scale_by = 0.6
    for uid in [0xea71]:
        print(uid)
        g = scaled_f.createChar(uid)
        symbol = symbols[uid]
        g.layers[0] = symbol.background
        g.layers[1] = symbol.foreground
        g.transform(
            psMat.compose(psMat.compose(
              psMat.translate(-c_x, -c_y),
              psMat.scale(scale_by)),
              psMat.translate(c_x, c_y))
        )
        g.width = symbol.width
        g.vwidth = symbol.vwidth

    scaled_f.generate("SymbolsScaled.ttf")
  '';

  symbols_scaled = pkgs.stdenv.mkDerivation {
    name = "l3mon-symbols-scaled-ttf";
    pname = "l3mon-symbols-scaled-ttf";
    phases = [ "installPhase" ];
    installPhase = ''
      ${gen_scaled_font}/bin/gen_scaled_font
      mkdir -p $out/share/fonts/
      cp SymbolsScaled.ttf $out/share/fonts/
    '';
  };

  noto_emoji_only = pkgs.stdenv.mkDerivation {
    name = "l3mon-noto-emoji-only-ttf";
    pname = "l3mon-noto-emoji-only-ttf";
    phases = [ "installPhase" ];
    installPhase = ''
      cp ${pkgs.noto-fonts-color-emoji}/share/fonts/noto/NotoColorEmoji.ttf .
      ${pkgs.python3Packages.fonttools}/bin/ttx NotoColorEmoji.ttf
      ${pkgs.gnused}/bin/sed '
        s/<map .*name="uni0000".*//g; 
        s/<map .*name="uni000D".*//g;  
        s/<map .*name="numbersign".*//g;  
        s/<map .*name="asterisk".*//g;  
        s/<map .*name="zero".*//g;  
        s/<map .*name="one".*//g;  
        s/<map .*name="two".*//g;  
        s/<map .*name="three".*//g;  
        s/<map .*name="four".*//g;  
        s/<map .*name="five".*//g;  
        s/<map .*name="six".*//g;  
        s/<map .*name="seven".*//g;  
        s/<map .*name="eight".*//g;  
        s/<map .*name="nine".*//g;  
        s/<map .*name="copyright".*//g;  
        s/<map .*name="registered".*//g
      ' NotoColorEmoji.ttx > NotoColorEmojiOnly.ttf
      mkdir -p $out/share/fonts/
      cp NotoColorEmojiOnly.ttf $out/share/fonts
    '';
  };
in {
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
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.min-quantum" = 256;
      };
    };
  };

  services.gnome.gnome-keyring.enable = true;
  hardware.graphics.enable = true;

  # fonts.
  fonts = {
    packages = with pkgs; [
      l3mon.iosevka
      julia-mono
      nerdfonts_symbols_only
      symbols_scaled
      noto_emoji_only
    ];
    enableDefaultPackages = true;
  };

  environment.systemPackages = with pkgs; [
    foot.terminfo
    gparted
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

  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = "wlr";
      };
    };
    wlr.enable = true;
    wlr.settings.screencast = {
      output_name = "DP-1";
      chooser_type = "simple";
      chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
    };
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
  };

  home-manager.sharedModules = [
    (
      { config, lib, pkgs, machine, data, ... }:
      
      let
        cursor_theme_name = "phinger-cursors-light";
        cursor_size = 24;
        cursor_theme_package = pkgs.phinger-cursors;
      in {
        imports = [
          ./base.nix
          ./outputs.nix
          ./inputs.nix
          ./decoration.nix
          ./qbittorrent.nix
          ./waybar.nix
          ./workrooms
          ./copypaste
          ./screengrab.nix
          ./zathura.nix
        ];

        home.packages = with pkgs; [
          pass
          cursor_theme_package
          adapta-gtk-theme
          adapta-kde-theme
          sway_float
          xdragon
        ];

        wayland.windowManager.sway = {
          enable = true;
          systemd = {
            enable = true;
            # check teal:~/.bashrc.d/99-wm.sh
            variables = [
              # defaults extended with PATH.
              "DISPLAY"
              "WAYLAND_DISPLAY"
              "SWAYSOCK"
              "XDG_CURRENT_DESKTOP"
              "XDG_SESSION_TYPE"
              "NIXOS_OZONE_WL"
              "XCURSOR_THEME"
              "XCURSOR_SIZE"

              "PATH"
            ];
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

        l3mon.sway-netns.wg_rec_de = {
          enable = true;
          openPrivateWindow = true;
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
          config.common = {
            default = [
              "wlr"
              "gtk"
              "gnome"
            ];
            # https://github.com/NixOS/nixpkgs/issues/262286
            "org.freedesktop.impl.portal.Inhibit" = "none";

            "org.freedesktop.impl.portal.ScreenCast" = "wlr";
            "org.freedesktop.impl.portal.Screenshot" = "wlr";

            # GTK interfaces
            "org.freedesktop.impl.portal.FileChooser" = "gtk";
            "org.freedesktop.impl.portal.AppChooser" = "gtk";
            "org.freedesktop.impl.portal.Print" = "gtk";
            "org.freedesktop.impl.portal.Notification" = "gtk";
            # "org.freedesktop.impl.portal.Inhibit" = "gtk";
            "org.freedesktop.impl.portal.Access" = "gtk";
            "org.freedesktop.impl.portal.Account" = "gtk";
            "org.freedesktop.impl.portal.Email" = "gtk";
            "org.freedesktop.impl.portal.DynamicLauncher" = "gtk";
            "org.freedesktop.impl.portal.Lockdown" = "gtk";
            "org.freedesktop.impl.portal.Settings" = "gtk";
            "org.freedesktop.impl.portal.Wallpaper" = "gtk";

            # "org.freedesktop.impl.portal.Access" = "gnome";
            # "org.freedesktop.impl.portal.Account" = "gnome";
            # "org.freedesktop.impl.portal.AppChooser" = "gnome";
            "org.freedesktop.impl.portal.Background" = "gnome";
            "org.freedesktop.impl.portal.Clipboard" = "gnome";
            # "org.freedesktop.impl.portal.DynamicLauncher" = "gnome";
            # "org.freedesktop.impl.portal.FileChooser" = "gnome";
            "org.freedesktop.impl.portal.InputCapture" = "gnome";
            # "org.freedesktop.impl.portal.Lockdown" = "gnome";
            # "org.freedesktop.impl.portal.Notification" = "gnome";
            # "org.freedesktop.impl.portal.Print" = "gnome";
            "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
            # "org.freedesktop.impl.portal.ScreenCast" = "gnome";
            # "org.freedesktop.impl.portal.Screenshot" = "gnome";
            # "org.freedesktop.impl.portal.Settings" = "gnome";
            # "org.freedesktop.impl.portal.Wallpaper" = "gnome";
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
            # gtk-theme-name="vimix-light-doder";
            # gtk-icon-theme-name="Papirus";
            # gtk-font-name="Sans 10";
            # gtk-toolbar-style="GTK_TOOLBAR_BOTH";
            # gtk-toolbar-icon-size="GTK_ICON_SIZE_LARGE_TOOLBAR";
            # gtk-button-images="1";
            # gtk-menu-images="1";
            # gtk-enable-event-sounds="1";
            # gtk-enable-input-feedback-sounds="1";
            # gtk-xft-antialias="1";
            # gtk-xft-hinting="1";
            # gtk-xft-hintstyle="hintfull";
            # gtk-xft-rgba="rgb";
          };
          # rounded corners don't fit with the theme.
          gtk3.extraCss = ''
            /* Remove rounded corners */
            .titlebar,
            .titlebar .background,
            decoration,
            window,
            window.background
            {
                border-radius: 0;
            }

            /* Remove csd shadows */
            decoration, decoration:backdrop
            {
                box-shadow: none;
            }
          '';
          font.name = "Inter:medium";
          theme.name = "adw-gtk3";
          theme.package = pkgs.adw-gtk3;
          iconTheme.name = "Papirus";
          iconTheme.package = pkgs.papirus-icon-theme;
        };

        # mkForce to override import of theme in css, which breaks these
        # user-css-settings. (at least for adw-gtk3).
        xdg.configFile."gtk-4.0/gtk.css".text = lib.mkForce ''
          /* Remove rounded corners */
          window
          {
              border-radius: 0;
          }

          /* Remove csd shadows */
          decoration, decoration:backdrop
          {
              box-shadow: none;
          }
        '';

        home.pointerCursor = {
          gtk.enable = true;
          x11.enable = true;
          package = cursor_theme_package;
          name = cursor_theme_name;
          size = cursor_size;
        };

        programs.foot = {
          enable = true;
          # up-to-date foot (~1.20.2+ from unstable) has fix for double-trigger
          # of Enter, Backspace, Tab https://codeberg.org/dnkl/foot/issues/1892
          # Add xdg-utils to path, s.t. xdg-open works.
          package = pkgs-unstable.foot.overrideAttrs (old: {
            nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.makeWrapper];
            postInstall = old.postInstall + ''
              wrapProgram $out/bin/foot \
                --prefix PATH : ${lib.makeBinPath [pkgs.xdg-utils]}
            '';
          });
          server.enable = true;
          settings = {
            main = {
              font =
                # "NotoColorEmojiOnly:size=10:antialias=true:autohint=true," +
                "iosevka:size=10:antialias=true:autohint=true," +
                "juliamono:size=10:antialias=true:autohint=true," +
                "codicon:size=10:antialias=true:autohint=true," +
                "Symbols Scaled:size=10:antialias=true:autohint=true," +
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
