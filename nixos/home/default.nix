{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./profiles/zotero.nix
  ];

  home.username = "simon";
  home.homeDirectory = "/home/simon";

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/dotfiles/nvim";

  home.file.".ssh/id_rsa".source = config.lib.file.mkOutOfStoreSymlink "/var/secrets/id_rsa";
  home.file.".ssh/id_rsa.pub".source = config.lib.file.mkOutOfStoreSymlink "/var/secrets/id_rsa.pub";

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = [
      "${pkgs.clang}"
      "${pkgs.tree-sitter}"
      "${pkgs.nodejs}"
      "${pkgs.luarocks}"
      "${pkgs.luajit}"
      "${pkgs.lua-language-server}"
    ];
    package = inputs.neovim-nightly.packages.${pkgs.system}.default;
  };


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
    np = "~/.local/share/nvim/lazy";
    nc = "~/projects/dotfiles/nvim";
    mc = "~/projects/nvim/matchconfig";
    lsn = "~/projects/nvim/luasnip";
  };
  programs.bash.enable = true;

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
