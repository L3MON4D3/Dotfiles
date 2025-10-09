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
          flake: shell_drv: let
            pkgs = (import <nixpkgs> {});
            collectFlakeInputs = input:
              ([ input ] ++ pkgs.lib.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or {})));
            all_inputs = (collectFlakeInputs flake) ++ [ flake.outputs.devShells.x86_64-linux.default ] ++ [ (import shell_drv).man (import shell_drv).out ];
          in pkgs.writeTextFile {
            name = "keep-devshell-full";
            text = builtins.concatStringsSep "," all_inputs;
          }
        '';
      in
      # bash
      ''
        # get pid of devshell -> get path to bashInteractive from /proc -> get derivation -> get path to out/man.
        # shellcheck disable=2016
        shellpath=$(echo 'readlink /proc/$$/exe' | nix develop)
        shell_drvpath="$(nix-store --query --deriver "$shellpath")"
        keep_flake_full="$(nix build --expr '{extra_deps}: import ./a.nix (builtins.getFlake (toString ./.)) extra_deps' --argstr extra_deps "$shell_drvpath" --impure --print-out-paths --no-link)"
        nix-store --add-root ./profile --indirect --realise "$keep_flake_full"
      '');
    })
  ];
}
