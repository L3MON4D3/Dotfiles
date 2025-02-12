{ config, lib, pkgs, machine, data, ... }:

{
  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value= true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      DisableFirefoxScreenshots = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
      FirefoxHome = {
        TopSites = false;
        SponsoredTopSites = false;
        SponsoredPocket = false;
      };
      # maybe override for home-network? OTOH, pass is as fast.
      OfferToSaveLoginsDefault = false;

      # always block.
      Permissions.Notifications.BlockNewRequests = true;

      DefaultDownloadDirectory = ''''${home}/downloads'';
      
      DisplayBookmarksToolbar = "never"; # alternatives: "always" or "newtab"
      DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
      SearchBar = "unified"; # alternative: "separate"
    };
  };
}
