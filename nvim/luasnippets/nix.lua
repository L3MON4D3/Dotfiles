parse_add("$", "\\${$1}")
parse_add("prof", [[
	{ config, lib, pkgs, machine, data, ... }:
	
	{
		$1
	}
]])
s_add("wsa", fmta([[
	<pkgs>.writeShellApplication {
		name = "<name>";<rti>
		text = ''
			<txt>
		'';
	}
]], {
	pkgs = i(1, "pkgs", {key = "pkgs"}),
	name = i(2, "name"),
	rti = c(3, {
		t"",
		fmta("\n\truntimeInputs = with <pkgsrep>; [<pkgs>];", {
			pkgsrep = l(l._1, {k"pkgs"}),
			pkgs = i(1)
		}, {trim_empty = false, dedent = false}),
	}),
	txt = i(4)
}))
