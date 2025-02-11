{ config, pkgs, lib, inputs, ... }:

{
  imports=[
    ./profiles/neovim.nix
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

  home.sessionVariables = {
    np =  "/home/simon/.local/share/nvim/lazy";
    nc =  "/home/simon/projects/dotfiles/nvim";
    mc =  "/home/simon/projects/nvim/matchconfig";
    lsn = "/home/simon/projects/nvim/luasnip";
    nx =  "/home/simon/projects/dotfiles/nixos/configuration.nix";
  };
  programs.bash.enable = true;

  programs.firefox.enable = true;
  programs.firefox.profiles = {
    default = {
      name = "default";
      isDefault = true;
      id = 0;
    };
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [ ];

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
