{ config, lib, pkgs, pkgs-unstable, machine, inputs, data, ... }:

let
  nvim = inputs.neovim-nightly.packages.${pkgs.system}.default;
in {
  home.activation.myNvimRepos = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p ${config.home.homeDirectory}/projects/dotfiles/nvim
    if [ ! -d "${config.home.homeDirectory}/projects/nvim/matchconfig" ]; then
      run ${pkgs.systemd}/lib/systemd/systemd-networkd-wait-online
      run ${pkgs.git}/bin/git clone http://git.internal/simon/matchconfig.git ${config.home.homeDirectory}/projects/nvim/matchconfig
    fi
    if [ ! -d "${config.home.homeDirectory}/projects/nvim/luasnip" ]; then
      run ${pkgs.systemd}/lib/systemd/systemd-networkd-wait-online
      run ${pkgs.git}/bin/git clone http://git.internal/simon/luasnip.git ${config.home.homeDirectory}/projects/nvim/luasnip
    fi

    echo 'return {"${nvim}/share/nvim/runtime"}' > "${config.home.homeDirectory}/projects/dotfiles/nvim/generated/rtp_base.lua"
  '';

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = [
      pkgs.clang
      pkgs.tree-sitter
      pkgs.nodejs
      pkgs.luajit
      pkgs.luarocks
      # julia for random scripts and lsp.
      pkgs-unstable.lua-language-server
      # make sure to install LanguageServer.jl, Images, Revise
      # Maybe use with 
      pkgs.julia-bin
      # clangd
      pkgs.clang-tools
      pkgs.python312Packages.ipython
      pkgs.pyright

      # preview markdown.
      pkgs.python312Packages.grip
    ];
    extraLuaPackages = ps: with ps; [
      luasocket
    ];
    package = nvim;
  };

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/dotfiles/nvim";
}
