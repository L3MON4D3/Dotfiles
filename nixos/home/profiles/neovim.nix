{ config, lib, pkgs, machine, inputs, data, ... }:

{
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
  '';
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



  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/dotfiles/nvim";
}
