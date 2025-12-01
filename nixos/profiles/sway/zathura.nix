{ config, lib, pkgs, machine, data, ... }:

{
  home.shellAliases = {
    za = "zathura --fork";
  };
  programs.zathura = {
    enable = true;
    package = (pkgs.zathura.override { useMupdf = true; });
  };
}
