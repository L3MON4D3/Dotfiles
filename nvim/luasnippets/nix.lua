parse_add("$", "\\${$1}")
parse_add("prof", [[
	{ config, lib, pkgs, machine, data, ... }:
	
	{
		$1
	}
]])
