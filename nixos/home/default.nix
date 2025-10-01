{ config, pkgs, lib, inputs, ... }:

{
  imports=[
    ./profiles/neovim/default.nix
    ./profiles/pass.nix
    ./profiles/jellyfin-mpv-shim.nix
    ./profiles/qutebrowser
    ./profiles/mpv.nix
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
    signing.signByDefault = true;
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
    au = "/srv/media/audio/original";
    vi = "/srv/media/video";
  };
  programs.bash.enable = true;
  # make sure profile is loaded (provides sessionVariables).
  # This is not done by default for login-shells, I think.
  programs.bash.bashrcExtra = ''
    source ~/.profile
  '';

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    pass
  ];

  xdg.configFile."nixpkgs/config.nix".text = ''
  {
    allowUnfree = true;
  }
  '';

  accounts.email = {
    accounts."simon@l3mon4.de" = {
      realName = "Simon Katz";
      address = "simon@l3mon4.de";

      primary = true;

      gpg = {
        key = "8F58312A929C1830A5E209C5076E7AE78280FE63";
        signByDefault = true;
      };

      imap = {
        host = "imap.mailbox.org";
        tls.useStartTls = true;
      };

      smtp = {
        host = "smtp.mailbox.org";
        tls.useStartTls = true;
      };
      userName = "simon@l3mon4.de";

      thunderbird.enable = true;
    };
    accounts."simljk@outlook.de" = {
      realName = "Simon Katz";
      address = "simljk@outlook.de";

      gpg = {
        key = "A2F3259407BA024D2827C8D64C6CA567EADBAF46";
        signByDefault = true;
      };

      imap = {
        host = "outlook.office365.com";
        tls.useStartTls = true;
      };

      smtp = {
        host = "smtp-mail.outlook.com";
        tls.useStartTls = true;
      };
      userName = "simljk@outlook.de";

      thunderbird = {
        enable = true;
        settings = id: {
          # oauth.
          "mail.server.server_${id}.authMethod" = 10;
          "mail.smtpserver.smtp_${id}.authMethod" = 10;
        };
      };
    };
    accounts."s6sikatz@uni-bonn.de" = {
      realName = "Simon Katz";
      address = "s6sikatz@uni-bonn.de";

      gpg = {
        key = "539486C322FDF9A5204718D66F6AA8BDF1F8BD04";
        signByDefault = true;
      };

      imap = {
        host = "email.uni-bonn.de";
        port = 993;
        tls.enable = true;
      };

      smtp = {
        host = "email.uni-bonn.de";
        port = 465;
        tls.enable = true;
      };
      userName = "s6sikatz";

      thunderbird.enable = true;
    };
  };

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
