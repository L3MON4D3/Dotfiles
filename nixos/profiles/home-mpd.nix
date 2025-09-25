{ config, lib, pkgs, machine, data, ... }:

{
  home-manager.sharedModules = [(
    { config, lib, pkgs, machine, data, inputs, ... }:
    let
      mpdlrc = pkgs.writeShellApplication {
          name = "mpdlrc";
          runtimeInputs = [ inputs.mpdlrc.defaultPackage.${pkgs.system} ];
          text = ''
            mpdlrc --musicdir=/srv/media/audio/original
          '';
        };
    in {
      services.mpd = {
        enable = true;
        musicDirectory = "/srv/media/audio/original";
        network = {
          listenAddress = "any"; 
          port = data.ports.mpd;
        };

        extraConfig = ''
          audio_output {
              type        "pipewire"
              name        "Pipewire"
              mixer_type  "software"
          }
        '';
      };

      home.packages = with pkgs; [
        mpdlrc
      ];

      programs.ncmpcpp = {
        enable = true;
        settings = {
          media_library_primary_tag = "album_artist";
          lyrics_fetchers = "musixmatch, azlyrics, genius, sing365, metrolyrics, justsomelyrics, jahlyrics, plyrics, tekstowo, internet";
          # can cause issues with long filenames, for now just disable it so
          # ncmpcpp doesn't crash on startup, but only when switching to lyrics
          # tab/fetching lyrics.
          fetch_lyrics_for_current_song_in_background = "no";
          external_editor = "nvim";
          use_console_editor = "yes";
        };
        bindings = [
          { key = "j"; command = "scroll_down"; }
          { key = "k"; command = "scroll_up"; }
          { key = "h"; command = "previous_column"; }
          { key = "l"; command = "next_column"; }
          { key = "."; command = "show_lyrics"; }
        ];
      };

      wayland.windowManager.sway.extraConfig = ''
        mode "apps" {
          bindsym n exec "$term ${pkgs.ncmpcpp}/bin/ncmpcpp"
          bindsym m exec "$term ${mpdlrc}/bin/mpdlrc"
        }
      '';
    }
  )];

  l3mon.restic.extraGroups = [ "simon" ];
  l3mon.restic.specs.mpd = {
    backup15min = {
      text = ''
        cd /home/simon/.local/share/mpd
        restic backup --tag=mpd-${machine} -- ./playlists
      '';
    };
    forget = {
      text = ''
        restic forget --tag=mpd-${machine} --group-by=tag --keep-weekly=4 --keep-monthly=12 --keep-yearly=unlimited
      '';
    };
  };
}
