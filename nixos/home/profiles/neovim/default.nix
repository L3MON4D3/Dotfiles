{ config, lib, pkgs, pkgs-unstable, machine, inputs, data, ... }:

let
  nvim = inputs.neovim-nightly.packages.${pkgs.stdenv.hostPlatform.system}.default;
  ngram_zip = pkgs.fetchurl {
    url = "https://languagetool.org/download/ngram-data/ngrams-en-20150817.zip";
    hash = "sha256-EOVIcx2fWBifw2pVP39oVwO+MNoNm7QtH3tb9fi7Iyw=";
  };
  ngrams = pkgs.runCommand "ngrams-unzip" {} ''
    mkdir -p $out
    ${pkgs.unzip}/bin/unzip ${ngram_zip} -d $out
    ln -s $out/en $out/en-US
  '';
  jetls = inputs.jetls.packages.${pkgs.stdenv.hostPlatform.system}.jetls;
  julia_fhs = config.lib.julia_fhs;
  # add tree-sitter from nvim-nightly package.
  # we need tree-sitter for building grammars from nvim-treesitter, and the
  # version in pkgs may be wrong.
  tree-sitter = (builtins.head (builtins.filter (x: x.name == "tree-sitter-bundled") inputs.neovim-nightly.packages.${pkgs.stdenv.hostPlatform.system}.neovim.buildInputs));
  wesl_treesitter_parser = "${tree-sitter.buildGrammar {
    src = pkgs.fetchFromGitHub {
      owner = "wgsl-tooling-wg";
      repo = "tree-sitter-wesl";
      rev = "3fa2b96bf5c217dae9bf663e2051fcdad0762c19";
      hash = "sha256-O3n65StgGhxfdwYF/QPBTdkXEGjY2ajHeLpF5JWuTc8=";
    };
    version = "1.0";
    language = "wesl";
  }}/parser";
in {
  home.activation.myNvimRepos = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p ${config.home.homeDirectory}/projects/dotfiles/nvim
    if [ ! -d "${config.home.homeDirectory}/projects/nvim/matchconfig" ]; then
      run ${pkgs.systemd}/lib/systemd/systemd-networkd-wait-online
      run ${pkgs.git}/bin/git clone https://git.internal/simon/matchconfig.git ${config.home.homeDirectory}/projects/nvim/matchconfig
    fi
    if [ ! -d "${config.home.homeDirectory}/projects/nvim/luasnip" ]; then
      run ${pkgs.systemd}/lib/systemd/systemd-networkd-wait-online
      run ${pkgs.git}/bin/git clone https://git.internal/simon/luasnip.git ${config.home.homeDirectory}/projects/nvim/luasnip
    fi
    if [ ! -d "${config.home.homeDirectory}/projects/nvim/togglecomment" ]; then
      run ${pkgs.systemd}/lib/systemd/systemd-networkd-wait-online
      run ${pkgs.git}/bin/git clone https://git.internal/simon/togglecomment.git ${config.home.homeDirectory}/projects/nvim/togglecomment
    fi

    echo 'return {"${nvim}/share/nvim/runtime"}' > "${config.home.homeDirectory}/projects/dotfiles/nvim/generated/rtp_base.lua"
    echo 'return "${ngrams}"' > "${config.home.homeDirectory}/projects/dotfiles/nvim/generated/ngram_path.lua"
    echo 'return "${jetls}/bin/jetls"' > "${config.home.homeDirectory}/projects/dotfiles/nvim/generated/jetls_bin.lua"
    echo 'return "${julia_fhs.drvPath}"' > "${config.home.homeDirectory}/projects/dotfiles/nvim/generated/julia_fhs_drvpath.lua"
    echo 'return { wesl = "${wesl_treesitter_parser}"}' > "${config.home.homeDirectory}/projects/dotfiles/nvim/generated/ts_parsers.lua"
  '';

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = [
      # for building treesitter grammars.
      tree-sitter
      pkgs.zig
      pkgs.nodejs
      pkgs.luajit
      pkgs.luarocks

      inputs.jetls.packages.${pkgs.stdenv.hostPlatform.system}.jetls

      pkgs-unstable.lua-language-server
      pkgs.pyright
      # make sure to install LanguageServer.jl, Images, Revise
      # clangd
      pkgs.clang-tools
      pkgs.python312Packages.ipython

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
