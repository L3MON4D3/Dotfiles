{ config, lib, pkgs, machine, data, ... }:

let
  screenrec = pkgs.writeShellApplication {
    name = "screenrec";
    runtimeInputs = with pkgs; [
      # pgrep, pkill
      procps
      # date
      coreutils
      wf-recorder
      libnotify
      sway
      jq
      slurp
    ];
    text = ''
      if pgrep -x "wf-recorder" > /dev/null
      then
          pkill -SIGINT wf-recorder
          notify-send -t 5000 Finished recording
      else
          wf-recorder -g "$(swaymsg -t get_tree | jq -r '.. | (.nodes? // empty)[] | select(.pid and .visible) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | slurp)" --file="$(date "+%s")".mp4
      fi
    '';
  };
  windowshot = pkgs.writeShellApplication {
    name = "windowshot";
    runtimeInputs = with pkgs; [
      sway
      jq
      grim
      slurp
    ];
    text = ''
      grim -g "$( {
        swaymsg -t get_tree | jq -r '.. | (.nodes? // empty)[] | select(.pid and .visible) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' ;
        swaymsg -t get_tree | jq -r '.. | (.floating_nodes? // empty)[] | select(.pid and .visible) | .rect | "\(.x+1),\(.y) \(.width-2)x\(.height-1)"' ; } | slurp)" /tmp/screen.png
    '';
  };
  slurpscreen = pkgs.writeShellApplication {
    name = "slurpscreen";
    runtimeInputs = with pkgs; [
      slurp
      grim
    ];
    text = ''
      grim -g "$(slurp)" /tmp/screen.png
    '';
  };
  popout = pkgs.writeShellApplication {
    name = "popout";
    runtimeInputs = with pkgs; [
      # mktemp
      coreutils
      slurp
      grim
      perl
      # identify
      imagemagick
      sway
      imv
    ];
    text = ''
      FILE=$(mktemp -u /tmp/popout_XXXX)
      SLURP=$(slurp)
      grim -g "$SLURP" "$FILE"

      X=$(echo "$SLURP" | perl -lpe 's/(\d+),\d+.*/$1/g')
      Y=$(echo "$SLURP" | perl -lpe 's/\d+,(\d+).*/$1/g')
      echo "$X $Y"

      WIDTH=$(identify "$FILE" | perl -lpe 's/.* (\d+)x\d+ .*/$1/g')
      HEIGHT=$(identify "$FILE" | perl -lpe 's/.* \d+x(\d+) .*/$1/g')

      swaymsg 'for_window [title="^imv .*'"$FILE"'.*"] "floating enable, move absolute position '"$X"' '"$Y"'"'

      # none: no scaling.
      imv "$FILE" -W "$WIDTH" -H "$HEIGHT" -s none
    '';
  };
in {
  wayland.windowManager.sway.extraConfig = ''
    mode "screen" {
      bindsym r exec ${screenrec}/bin/screenrec
      bindsym s exec ${slurpscreen}/bin/slurpscreen
      bindsym d exec ${pkgs.xdragon}/bin/dragon "/tmp/screen.png"
      bindsym w exec ${windowshot}/bin/windowshot
      bindsym p exec ${popout}/bin/popout
        bindsym Return mode "default"
        bindsym Escape mode "default"
    }
    bindsym $mod+s mode "screen"
  '';
}
