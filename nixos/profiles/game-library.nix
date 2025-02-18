{ config, lib, l3lib, pkgs, machine, data, ... }:

let
  update_steam = pkgs.writeShellApplication {
    name = "update_steam";
    text = ''
      gamedefs=(
        # # Trackmania
        # "2225070:windows"
        # # Dominion
        # "1131620:windows"
        # Katana ZERO
        "460950:windows"
        # Old World
        "597180:linux"
        # AoM
        "266840:windows"
        # Enter the Gungeon
        "311690:linux"
        # Fall Guys
        "1097150:windows"
        # # Garrys Mod
        # "4000:linux"
        # # Human: Fall Flat
        # "477160:windows"
        # # Humankind
        # "1124300:windows"
        # # It takes two friends pass
        # "1504980:windows"
        # # Portal 2
        # "620:linux"
        # # Satisfactory
        # "526870:windows"
        # # ShellShock Live
        # "326460:linux"
        # # Civ 6
        # "289070:linux"
        # # Stardew Valley
        # "413150:linux"
        # # Stellaris
        # "281990:linux"
        # Tabletop Simulator
        "286160:linux"
        # # Undertale
        # "391540:linux"
        # Duck Game
        "312530:windows"
        # # invisible inc
        # "243970:linux"
        # Stick Fight
        "674940:windows"
        # # terraria
        # "105600:linux"
        # # TM Nations
        # "11020:windows"
        # # Deep Rock Galactic 
        # "548430:windows"
        # # Among Us
        # "945360:windows"
        # # BF2042
        # "1517290:windows"
        # PlateUp!
        "1599600:windows"
      )

      export HOME=/var/lib/steam/cmd
      for gamedef in "''${gamedefs[@]}"
      do
        IFS=: read -r gameid platform <<< "$gamedef"
        # set platform before attempting to install game..
        # steamcmd runs through commands and immediately executes them.
        # (I guess that makes sense, and the + somewhat indicates it)
        # download_throttle specified in kiloBIT/second! 14400/8=1800.
        ${pkgs.steamcmd}/bin/steamcmd +login l3mon4d3 "$(cat "$CREDENTIALS_DIRECTORY"/passwd)" \
            +set_download_throttle 14400 \
            +@sSteamCmdForcePlatformType "$platform" \
            +app_update "$gameid" validate \
            +quit
      done
    '';
  };
  update_gog = pkgs.writeShellApplication {
    name = "update_gog";
    text = ''
      gamedefs=(
        "mdk:windows"
        # "oxenfree:windows"
        # "baldurs_gate_iii:windows"
        # "cyberpunk_2077_game:windows"
      )

      cd /srv/games/gog/
      export HOME=/var/lib/gog
      for gamedef in "''${gamedefs[@]}"
      do
        IFS=: read -r gamename platform <<< "$gamedef"

        echo "$gamename $platform"

        ${pkgs.lgogdownloader}/bin/lgogdownloader --galaxy-arch=x64 \
                --galaxy-language=en \
                --galaxy-no-dependencies \
                --delete-orphans \
                --subdir-galaxy-install="%title%" \
                --galaxy-platform="$platform" \
                --galaxy-install="$gamename" \
                --progress-interval=10000
      done
    '';
  };
in {
  # for clients: nfs-mount this share.
  fileSystems."/srv/nfs/steamlib" = {
    device = "/var/lib/steam/library";
    options = [ "bind" ];
  };
  fileSystems."/srv/nfs/gog" = {
    device = "/srv/games/gog";
    options = [ "bind" ];
  };

  services.nfs.server.exports = ''
    /srv/nfs/steamlib 192.168.178.0/24(rw)
    /srv/nfs/gog      192.168.178.0/24(rw)
  '';

  #
  # Prepare env for steamcmd and gog
  #

  # steamcmd uses .local/share/Steam/steamapps as its library and I can't
  # figure out how to change that -> just place library there.
  # symlink is overwritten, use bindmount instead :/
  fileSystems."/var/lib/steam/cmd/.local/share/Steam/steamapps" = {
    device = "/var/lib/steam/library/steamapps";
    options = [ "bind" ];
  };

  systemd.tmpfiles.rules = [
    "Z /var/lib/steam                                  0750 simon simon"
    "d /var/lib/steam/library                          0750 simon simon"
    "d /var/lib/steam/cmd                              0750 simon simon"
    "d /var/lib/steam/cmd/.steam                              0750 simon simon"
    "L /var/lib/steam/cmd/.steam/root - - - - /var/lib/steam/cmd/.local/share/Steam"
    "L /var/lib/steam/cmd/.steam/steam - - - - /var/lib/steam/cmd/.local/share/Steam"
    "d /var/lib/steam/cmd/.local/share 0750 simon simon"
    "d /var/lib/steam/cmd/.local/share/Steam 0750 simon simon"
    "d /var/lib/steam/cmd/.local/share/Steam/steamapps 0750 simon simon"
    "d /var/lib/steam/local/compatdata                 0750 simon simon"
    "d /var/lib/steam/local/shadercache                0750 simon simon"

    "d /var/lib/gog                          0750 simon simon"
    "d /srv/games 0750 simon simon"
    "d /srv/games/gog 0750 simon simon"
  ];

  systemd.timers.update-games = {
    enable = true;
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 04:00:00";
    };
  };
  systemd.services.update-games = {
    description = "Update Steam and GOG-Games";
    after = [ "network-online.target" "blocky_lan.service" ];
    requires = [ "network-online.target" "blocky_lan.service" ];
    serviceConfig = {
      LoadCredential = "passwd:${l3lib.secret "steam_password"}";
      User = "simon";
      Group = "simon";
    };
    script = ''
      update_gog
      update_steam
    '';
    path = [ update_steam update_gog ];
  };
}
