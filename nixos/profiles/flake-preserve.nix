{ config, lib, pkgs, machine, data, ... }:

{
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellApplication {
      name = "devshell-preserve";
      runtimeInputs = with pkgs; [ nix jq ];
      text = (let
        preserve-flake-srcs = pkgs.writeText "preserve-flake-srcs"
        # nix
        ''
          flake: shell_drv_path: let
            pkgs = import ${pkgs.path} {};
            collectFlakeInputs = input:
              ([ input ] ++ pkgs.lib.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or {})));
            shell_drv = import shell_drv_path;
          in (flake.outputs.devShells.x86_64-linux.default.overrideAttrs (old: {
            inputSrcs = (if old ? "inputSrcs" then old.inputSrcs else []) ++ (builtins.tail (collectFlakeInputs flake));
            inputDrvs = (if old ? "inputDrvs" then old.inputDrvs else []) ++ [ shell_drv.man shell_drv.out ];
          }))
        '';
      in
      # bash
      ''
        # get pid of devshell -> get path to bashInteractive from /proc -> get derivation -> get path to out/man.
        # shellcheck disable=2016
        shellpath=$(echo 'readlink /proc/$$/exe' | nix develop)
        shell_drvpath="$(nix-store --query --deriver "$shellpath")"
        # pipe into devshells prevents interactive session.
        echo exit 0 | nix develop --expr 'import ${preserve-flake-srcs} (builtins.getFlake "git+file://'"$(pwd)"'") '"$shell_drvpath" --impure --profile ./profile
      '');
    })
  ];
}
