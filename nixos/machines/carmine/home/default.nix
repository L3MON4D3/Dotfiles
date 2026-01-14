{ config, lib, pkgs, machine, data, nur, inputs, ... }:

{
  imports = [
    ./profiles/sway-io.nix
    ./profiles/jellyfin-conf.nix
    ./profiles/store-secrets.nix
  ];
  l3mon.sway = {
    workrooms.enable = true;
    outputs = [ "DP-1" "HDMI-A-1" ];
  };
  l3mon.sway-netns.home = {
    enable = true;
    openPrivateWindow = false;
    netnsKey = "h";
    landingPage = "http://git.internal";
    firefoxProfileSettings = {
      id = 1;
      extensions.packages = with nur.repos.rycee.firefox-addons; [
        ublock-origin
        passff
      ];
    };
  };

  l3mon.sway-netns.rec_de = {
    enable = true;
    openPrivateWindow = true;
    netnsKey = "d";
    landingPage = "https://mullvad.net/en/check";
    firefoxProfileSettings = {
      id = 2;
      extensions.packages = with nur.repos.rycee.firefox-addons; [
        ublock-origin
        passff
        inputs.aa-torrent-dl.packages.${pkgs.stdenv.hostPlatform.system}.extension
        inputs.nvim-browseredit.packages.${pkgs.stdenv.hostPlatform.system}.extension
      ];
    };
  };
}
