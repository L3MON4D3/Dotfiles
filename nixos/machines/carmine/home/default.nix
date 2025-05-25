{ config, lib, pkgs, machine, data, nur, ... }:

{
  imports = [
    ./profiles/sway-io.nix
    ./profiles/jellyfin-conf.nix
  ];
  l3mon.sway = {
    workrooms.enable = true;
    outputs = [ "DP-1" "HDMI-A-1" ];
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
}
