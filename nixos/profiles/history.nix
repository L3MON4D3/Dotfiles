{ config, lib, pkgs, machine, data, ... }:

{
  environment.variables = {
    HISTCONTROL="erasedups";
    HISTSIZE=100000;
    SAVEHIST=100000;
    # hehe
    PROMPT_COMMAND="history -a;$PROMPT_COMMAND";
  };
}
