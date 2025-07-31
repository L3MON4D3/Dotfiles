{ config, lib, pkgs, machine, data, ... }:

let
  lan = data.network.lan;
in {
  environment.systemPackages = [
    (pkgs.writeShellApplication {
        name = "wake";
        runtimeInputs = [ pkgs.wakeonlan ];
        text = ''
          case "$1" in
        '' + (lib.attrsets.foldlAttrs (acc: k: v: acc + (if v ? "mac" then ''
          ${k})
            wakeonlan ${v.mac}
            ;;
        '' else "") ) "" lan.peers) + ''
          *)
            printf "Pass a valid machine-name!"
          esac
        '';
    })
  ];
}
