require("plugins.luasnip.helpers").setup_snip_env()

local rec_ls
rec_ls = function()
	return sn(nil, {
		c(1, {
			t({""}),
			sn(nil, {t({"", "\t\\item "}), i(1), d(2, rec_ls, {})}),
		}),
	})
end

return {
	ls.parser.parse_snippet({trig = ";"}, "\\$$1\\$$0"),
	s({trig = "(s*)sec", wordTrig = true, regTrig = true}, {
		f(function(args, snip) return {"\\"..string.rep("sub", string.len(snip.captures[1]))} end, {}),
		t({"section{"}), i(1), t({"}", ""}), i(0)
	}),
	ls.parser.parse_snippet({trig = "beg", wordTrig = true}, "\\begin{$1}\n\t$2\n\\end{$1}"),
	ls.parser.parse_snippet({trig = "beq", wordTrig = true}, "\\begin{equation*}\n\t$1\n\\end{equation*}"),
	ls.parser.parse_snippet({trig = "bal", wordTrig = true}, "\\begin{aligned}\n\t$1\n\\end{aligned}"),
	ls.parser.parse_snippet({trig = "ab", wordTrig = true}, "\\langle $1 \\rangle"),
	ls.parser.parse_snippet({trig = "lra", wordTrig = true}, "\\leftrightarrow"),
	ls.parser.parse_snippet({trig = "Lra", wordTrig = true}, "\\Leftrightarrow"),
	ls.parser.parse_snippet({trig = "fr", wordTrig = true}, "\\frac{$1}{$2}"),
	ls.parser.parse_snippet({trig = "tr", wordTrig = true}, "\\item $1"),
	ls.parser.parse_snippet({trig = "abs", wordTrig = true}, "\\|$1\\|"),
	s("ls", {
		t({"\\begin{itemize}",
		"\t\\item "}), i(1), d(2, rec_ls, {}),
		t({"", "\\end{itemize}"}), i(0)
	})
}
