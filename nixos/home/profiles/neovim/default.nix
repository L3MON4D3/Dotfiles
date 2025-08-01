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
    if [ ! -d "${config.home.homeDirectory}/projects/nvim/togglecomment" ]; then
      run ${pkgs.systemd}/lib/systemd/systemd-networkd-wait-online
      run ${pkgs.git}/bin/git clone http://git.internal/simon/togglecomment.git ${config.home.homeDirectory}/projects/nvim/togglecomment
    fi

    echo 'return {"${nvim}/share/nvim/runtime"}' > "${config.home.homeDirectory}/projects/dotfiles/nvim/generated/rtp_base.lua"
  '';

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = [
      # add tree-sitter from nvim-nightly package.
      # we need tree-sitter for building grammars from nvim-treesitter, and the
      # version in pkgs may be wrong.
      (builtins.head (builtins.filter (x: x.name == "tree-sitter-bundled") inputs.neovim-nightly.packages.${pkgs.system}.neovim.buildInputs))
      # for building treesitter grammars.
      pkgs.zig
      pkgs.nodejs
      pkgs.luajit
      pkgs.luarocks

      pkgs-unstable.lua-language-server
      pkgs.pyright
      # make sure to install LanguageServer.jl, Images, Revise
      # clangd
      pkgs.clang-tools
      pkgs.python312Packages.ipython

      (import ./julia-lsp.nix { pkgs = pkgs; })

      # lldb-dap
      pkgs.lldb

      # preview markdown.
      (pkgs.python312Packages.grip.overrideAttrs (prev: {
        src = pkgs.fetchFromGitHub {
          owner = "nikolavp";
          repo = "grip";
          rev = "add-mermaid-support";
          hash = "sha256-cRC+vst/W0pZosZXAOey4WtcLNOL8THRJ+5bhcCRdZw=";
        };
        patches = [];
        # not all checks pass on that branch :/
        checkPhase = "";
        installCheckPhase = "";
      }))
    ];
    extraLuaPackages = ps: with ps; [
      luasocket
    ];
    package = nvim;
  };

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/dotfiles/nvim";
}
