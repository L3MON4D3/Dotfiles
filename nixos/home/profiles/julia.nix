{ config, lib, pkgs, machine, data, scientific-fhs, ... }:

{
  home.file.".julia/config/startup.jl".text = ''
    using Revise

    using Images

    global imv_proc
    global imv_pid = -1
    fname_png = "/tmp/julia_image.png"
    function Base.display(i::Matrix{RGBA{N0f8}})
      save(fname_png, i)
      if imv_pid == -1
        global imv_proc = run(`imv $fname_png`, wait = false)
        global imv_pid = getpid(imv_proc)
        atexit() do
          kill(imv_proc)
        end
      end
    end
    function Base.display(i::Matrix{RGB{N0f8}})
      save(fname_png, i)
      if imv_pid == -1
        global imv_proc = run(`imv $fname_png`, wait = false)
        global imv_pid = getpid(imv_proc)
        atexit() do
          kill(imv_proc)
        end
      end
    end

    global tev_proc
    global tev_pid = -1
    fname_exr = "/tmp/julia_image.exr"
    function Base.display(i::Matrix{RGB{Float16}})
      save(fname_exr, i)
      run(`tev $fname_exr`, wait = false)
    end
  '';

  home.packages = with pkgs; [
    (pkgs.writeShellApplication (let
      # the unsafe is okay here because we want nixos-rebuild to only build the derivation, and then `nix develop ...` will actually build the derivation.
      fhs_path = (builtins.unsafeDiscardOutputDependency (scientific-fhs.override{ enableQuarto=true; enableJulia=true; juliaVersion = "1.11.6"; commandScript = "julia"; }).env.drvPath);
    in {
      name = "julia";
      text = ''
        nix develop "${fhs_path}"
      '';
    }))
    imv
    (tev.overrideAttrs (final: prev: {
      patches = (if prev ? patches then prev.patches else []) ++ [
        ./tev.patch
      ];
    }))
  ];
  home.shellAliases = {
    jl = "julia";
  };
}
