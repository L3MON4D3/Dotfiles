{ config, lib, pkgs, machine, data, nur, ... }:

{
  imports = [
    ./profiles/sway-io.nix
    ./profiles/jellyfin-mpv-cred.nix
  ];

  l3mon.sway = {
    workrooms.enable = false;
    outputs = [ "eDP-1" ];
  };
  l3mon.sway-netns.wg_mv_cb_de = {
    enable = true;
    openPrivateWindow = true;
    netnsKey = "d";
    landingPage = "https://mullvad.net/en/check";
    firefoxProfileSettings = {
      id = 1;
      extensions = with nur.repos.rycee.firefox-addons; [
        ublock-origin
        passff
      ];
    };
  };

  home.packages = with pkgs; [
    brightnessctl
  ];
}
