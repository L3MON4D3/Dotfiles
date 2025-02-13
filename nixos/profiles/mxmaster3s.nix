{ config, lib, pkgs, machine, data, inputs, system, ... }:

{
  # gives special udev-rules needed by solaar.
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
  
  # use up-to-date solaar from flake.
  nixpkgs.overlays = [
    (final: prev: {
      solaar = inputs.solaar.outputs.packages.${system}.solaar;
    })
  ];
  
  home-manager.sharedModules = [
    (
      { config, lib, pkgs, machine, data, ... }:

      {
        systemd.user.services.solaar = {
          Unit = {
            Description = "solaar";
            Wants = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.solaar}/bin/solaar --window=hide";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
          Install = {
            WantedBy = ["graphical-session.target"];
          };
        };

        xdg.configFile."solaar".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/dotfiles/solaar";
      }
    )
  ];
}
