{ config, pkgs, lib, inputs, nur, aa-torrent-dl, ... }:

{
  imports=[
    ./profiles/neovim/default.nix
    ./profiles/pass.nix
    ./profiles/jellyfin-mpv-shim.nix
    ./profiles/qutebrowser
    ./profiles/mpv.nix
    ./profiles/mpd.nix
    ./profiles/julia.nix
    ./profiles/mime.nix

    ./modules/sway-workrooms
    ./modules/sway.nix
  ];
  home.username = "simon";
  home.homeDirectory = "/home/simon";

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  programs.git = {
    enable = true;
    userName = "Simon Katz";
    userEmail = "simon@l3mon4.de";
    extraConfig = {
      init.defaultBranch = "main";
      github = {
        user = "L3MON4D3";
        userName = "L3MON4D3";
      };
      pull = {
        rebase = false;
      };
    };
    aliases = {
      log1 = "log --pretty='%C(auto)%h: %s'";
      l    = "log --pretty='%C(auto)%h: %s'";
      log2 = "log --pretty='%C(auto)%h: %s%C(dim white) ~%an' --graph";
      g    = "log --pretty='%C(auto)%h: %s%C(dim white) ~%an' --graph";
      s = "status";
      rc = "rebase --continue";
      p = "push";
      c = "checkout";
      bg = "bisect good";
      bb = "bisect bad";
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      wildhorn = {
        # host = "wildhorn";

        hostname = "wildhorn.cs.uni-bonn.de";
        identityFile = "~/.ssh/id_rsa";
        identitiesOnly = true;
        user = "katz";
      };
      rem = {
        # host = "rem";

        hostname = "remarkable";
        # identityFile = "~/.ssh/remarkable";
        identitiesOnly = true;
        user = "root";
      };
    };
  };

  home.sessionVariables = {
    np =  "/home/simon/.local/share/nvim/lazy";
    nc =  "/home/simon/projects/dotfiles/nvim";
    mc =  "/home/simon/projects/nvim/matchconfig";
    tc =  "/home/simon/projects/nvim/togglecomment";
    lsn = "/home/simon/projects/nvim/luasnip";
    lsi = "/home/simon/projects/nvim/luasnip-issues";
    nx =  "/home/simon/projects/dotfiles/nixos/configuration.nix";
    ms = "/home/simon/projects/master";
  };
  programs.bash.enable = true;
  # make sure profile is loaded (provides sessionVariables).
  # This is not done by default for login-shells, I think.
  programs.bash.bashrcExtra = ''
    source ~/.profile
  '';

  # https://discourse.nixos.org/t/hm-24-11-firefox-with-passff-host/57108
  # reenable nativeMessagingHost once the mentioned PR is merged.
  # home.file.passff-host-workaround = {
    # target = "${config.home.homeDirectory}/.mozilla/native-messaging-hosts/passff.json";
    # source = "${pkgs.passff-host}/share/passff-host/passff.json";
  # };

  programs.firefox = {
    enable = true; 
    nativeMessagingHosts = [
      pkgs.passff-host
      aa-torrent-dl.native-app
    ];
    package = pkgs.firefox-wayland;
    profiles = {
      default = {
        name = "default";
        isDefault = true;
        id = 0;
        settings = {
          # these can't be set via policies.
          "widget.use-xdg-desktop-portal.file-picker" = 1;
          "browser.aboutConfig.showWarning" = false;
          "browser.compactmode.show" = true;
          "widget.disable-workspace-management" = true;
        };
        search = {
          force = true;
          # from https://gitlab.com/usmcamp0811/dotfiles/-/blob/fb584a888680ff909319efdcbf33d863d0c00eaa/modules/home/apps/firefox/default.nix
          engines = {
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "type"; value = "packages"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];
              icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "NixOS Wiki" = {
              urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
              icon = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@nw" ];
            };
            google.metaData.alias = "@g";
          };
        };
        extensions.packages = with nur.repos.rycee.firefox-addons; [
          ublock-origin
          passff
          aa-torrent-dl.extension
        ];
      };
    };
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    pass
    legcord
    wl-clipboard
    # thunderbird is configured in-app, I know, bad, but email-settings are
    # pretty much set and forget, so that's fine I guess.
    # Settings include
    # * GNUPG
    # * date format https://support.mozilla.org/en-US/kb/customize-date-time-formats-thunderbird
    # via config editor.
    thunderbird
  ];

  wayland.windowManager.sway.extraConfig = ''
    mode "apps" {
      bindsym d exec legcord
      bindsym t exec thunderbird
    }
  '';

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  xdg.configFile."nixpkgs/config.nix".text = ''
  {
    allowUnfree = true;
  }
  '';

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
