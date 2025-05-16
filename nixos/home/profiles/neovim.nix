{ config, lib, pkgs, machine, inputs, data, ... }:

let
  nvim = inputs.neovim-nightly.packages.${pkgs.system}.default;

  update_rtpath_file_script = pkgs.writeText "update_rtp_file" ''
    local rtp = vim.api.nvim_get_runtime_file("", true)
    vim.fn.writefile({"return " .. vim.inspect(rtp)}, "${config.home.homeDirectory}/projects/dotfiles/nvim/generated/rtp_base.lua")
  '';
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

    ${nvim}/bin/nvim -u none -l ${update_rtpath_file_script}
  '';

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = [
      pkgs.clang
      pkgs.tree-sitter
      pkgs.nodejs
      pkgs.luarocks
      # julia for random scripts and lsp.
      pkgs.lua-language-server
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
