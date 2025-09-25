{ config, lib, pkgs, machine, data, inputs, system, ... }:

let
  audio_dir = "/srv/media/audio/original";
  playlist_dir = "/srv/media/audio/playlists";
  lossy_playlist_dir = "/srv/media/audio/lossy_playlists";
in {
  home-manager.sharedModules = [(
    { config, lib, pkgs, machine, data, inputs, ... }:
    let
      mpdlrc = pkgs.writeShellApplication {
          name = "mpdlrc";
          runtimeInputs = [ inputs.mpdlrc.defaultPackage.${pkgs.system} ];
          text = ''
            mpdlrc --musicdir=${audio_dir}
          '';
        };
    in {
      services.mpd = {
        enable = true;
        musicDirectory = audio_dir;
        playlistDirectory = playlist_dir;
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

  # for opus-fs.
  programs.fuse.userAllowOther = true;

  systemd.services.playlist-fs = {
    enable = true;
    unitConfig.RequiresMountsFor = [ audio_dir playlist_dir lossy_playlist_dir ];
    serviceConfig = {
      Type = "exec";
      User = "simon";
      Group = "simon";
    };
    path = [ inputs.dirmap.packages.${system}.default ];
    environment = {
      ORIGINAL_AUDIO_ROOT = audio_dir;
      PLAYLIST_TARGET_ROOT = playlist_dir;
      LOSSY_PLAYLIST_ROOT = lossy_playlist_dir;
      ANDROID_AUDIO_ROOT_PATTERN = "FF7F-A5BA/media/audio";
    };
    script = ''
      mkdir -p ${playlist_dir}
      chown simon:media ${playlist_dir}
      playlist-fs -f -o ro,allow_other
    '';
    preStop = ''
      ${config.security.wrapperDir}/fusermount -u ${playlist_dir}
    '';
  };

  l3mon.restic.extraGroups = [ "simon" ];
  l3mon.restic.specs.mpd = {
    backup15min = {
      text = ''
        cd /srv/media/audio
        restic backup --tag=playlists -- playlists
      '';
    };
    forget = {
      text = ''
        restic forget --tag=playlists --group-by=tag --keep-weekly=4 --keep-monthly=12 --keep-yearly=unlimited
      '';
    };
  };
}
