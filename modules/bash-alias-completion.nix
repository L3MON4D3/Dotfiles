{ config, lib, pkgs, data, ... }:

{
  # insert statements for complete-aliasing immediately after the aliases are
  # set up.
  programs.bash.interactiveShellInit = lib.mkOrder 1001 ''
    source ${pkgs.complete-alias}/bin/complete_alias
    complete -F _complete_alias "''${!BASH_ALIASES[@]}"
  '';
}
