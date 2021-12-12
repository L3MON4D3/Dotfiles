require("plugins.luasnip.helpers").setup_snip_env()

return {
	s({trig="if", wordTrig=true}, {
		t({"if "}),
		i(1),
		t({" then", "\t"}),
		i(0),
		t({"", "end"})
	}),
	s({trig="ee", wordTrig=true}, {
		t({"else", "\t"}),
		i(0),
	}),
	s("for", {
		t"for ", c(1, {
			sn(nil, {i(1, "k"), t", ", i(2, "v"), t" in ", c(3, {t"pairs", t"ipairs"}), t"(", i(4), t")"}),
			sn(nil, {i(1, "i"), t" = ", i(2), t", ", i(3), })
		}), t{" do", "\t"}, i(0), t{"", "end"}
	})
}
