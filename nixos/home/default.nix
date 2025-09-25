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
      indigo = {
        hostname = "indigo";
        remoteForwards = [
          {
            bind.address = "/run/user/1000/gnupg/S.gpg-agent";
            host.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
          }
        ];
      };
    };
  };

  services.gpg-agent = {
    enable = true;
    enableExtraSocket = true;
    # enableSshSupport = true;
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
