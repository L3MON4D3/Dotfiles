{ config, lib, pkgs, pkgs-unstable, machine, data, ... }:

with lib;
let
  custom-css =
  (
    # hide long video-descriptions.
    # css
    ''
      .listItem-overview bdi *:nth-child(n+2) {
        display: none !important;
      }

      .listItem-bottomoverview { display: none !important; }
    ''
  ) +
  (
    # hide played and a few manually-chosen skipped items in the Star Trek
    # playlist.
    # css
    ''
      .listItem[data-playlistid="91e612868ac3fa441f89b7ca3e1e9f26"]:has(.playedIndicator) {
          display: none !important;
      }

      .listItem[data-playlistid="91e612868ac3fa441f89b7ca3e1e9f26"]:where(
          [data-playlistitemid="b047f5e899026561ef2135e877bfbf75"],
          [data-playlistitemid="071a84c41284043d0676b82cfd8ced7c"],
          [data-playlistitemid="4b38016786d908e35b142119b4c6c789"],
          [data-playlistitemid="5260fa9bb841f8ee4bcefce4c0bb30fb"],
          [data-playlistitemid="57e3ea8f66203d531f0c435bbe312d29"],
          [data-playlistitemid="6db6497146313c81b4be2249eee04394"],
          [data-playlistitemid="6db6497146313c81b4be2249eee04394"],
          [data-playlistitemid="164417f2c0134b14ca9b588a463e36f8"],
          [data-playlistitemid="927bd8a614f25b948e97ec256fa48999"]
      ) {
          display: none !important;
      }
    ''
  );
  branding_file = pkgs.writeTextFile {
    name = "jellyfin-custom-css";
    text =
    # xml
    ''
      <?xml version="1.0" encoding="utf-8"?>
      <BrandingOptions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <LoginDisclaimer />
        <CustomCss>
      ${custom-css}
        </CustomCss>
        <SplashscreenEnabled>false</SplashscreenEnabled>
      </BrandingOptions>
    '';
  };
in {
  services.jellyfin.enable = true;
  services.jellyfin.package = pkgs-unstable.jellyfin;
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  system.activationScripts = {
    jellyfin-branding = {
      text =
      # bash
      ''
        install -D -o jellyfin -g jellyfin ${branding_file} ${config.services.jellyfin.configDir}/branding.xml
      '';
    };
  };
  
  l3mon.services.defs.jellyfin.cfg = data.ports.jellyfin_web;

  l3mon.restic.extraGroups = [ "jellyfin" ];
  users.users.jellyfin.extraGroups = [ "media" ];
  # allow group read-access so restic can read everything.
  systemd.services.jellyfin.serviceConfig.UMask = mkForce 0027;

  # override rules from jellyfin-module
  systemd.tmpfiles.settings.jellyfinDirs = {
    "${config.services.jellyfin.dataDir}"."d" = mkForce {
      mode = "750";
      inherit (config.services.jellyfin) user group;
    };
    "${config.services.jellyfin.configDir}"."d" = mkForce {
      mode = "750";
      inherit (config.services.jellyfin) user group;
    };
  };

  l3mon.restic = {
    specs.jellyfin = {
      # stop jellyfin while backup is running, then resume.
      backupStopResumeServices = [ "jellyfin.service" ];
      backupDaily = {
        text = ''
          cd ${config.services.jellyfin.dataDir}
          restic backup --tag=jellyfin --skip-if-unchanged=true -- data/ config/
        '';
      };
      forget = {
        text = ''
          restic forget --tag=jellyfin --group-by=tag --keep-daily=7 --keep-monthly=12
        '';
      };
    };
  };
}
