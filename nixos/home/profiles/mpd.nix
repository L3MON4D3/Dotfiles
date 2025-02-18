{ config, lib, pkgs, machine, data, ... }:

{
  services.mpd = {
    enable = true;
    musicDirectory = "/srv/media/audio";

    extraConfig = ''
      audio_output {
          type        "pipewire"
          name        "Pipewire"
          mixer_type  "software"
      }
    '';
  };

  programs.ncmpcpp = {
    enable = true;
    settings = {
      media_library_primary_tag = "album_artist";
      lyrics_fetchers = "musixmatch, azlyrics, genius, sing365, metrolyrics, justsomelyrics, jahlyrics, plyrics, tekstowo, internet";
      fetch_lyrics_for_current_song_in_background = "yes";
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
      bindsym n exec $term ${pkgs.ncmpcpp}/bin/ncmpcpp
    }
  '';
}
