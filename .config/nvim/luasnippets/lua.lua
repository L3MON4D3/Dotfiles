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
			sn(nil, {i(1, "k"), t", ", i(2, "v"), t" in ", c(3, {t"pairs", t"ipairs", i(nil)}), t"(", i(4), t")"}),
			sn(nil, {i(1, "i"), t" = ", i(2), t", ", i(3), })
		}), t{" do", "\t"}, i(0), t{"", "end"}
	}),
	s("while", fmt([[
	while {} do
		{}
	end
	]], ins_generate())),
	s("fn", fmt([[
		function{}({})
			{}
		end
	]], ins_generate({[3] = d(3, function(_, parent)
		if #parent.snippet.env.LS_SELECT_DEDENT ~= 0 then
			return sn(nil, {
				t(parent.snippet.env.LS_SELECT_DEDENT), t{"","\t"}, i(1)
			})
		else
			return sn(nil, { i(1) })
		end
	end)}))),
	s("str", fmt("[[\n\t{}\n]]", ins_generate())),
	s("sdt", fmt(
		[[ls_helpers.static_docstring_test({}, {}, {})]],
		{ i(1, "snip"), c(2, {{t"{\"", i(1), t"\"}"}, i(1)}), c(3, {{t"{\"", i(1), t"$0\"}"}, i(1)}) } )
	),
	s("lar", fmt(
		"${{{}}}",
		{ i(1) }
	)),
	s({trig = "lar(%d)", regTrig = true, wordTrig = false}, fmt(
		"${{{}:{}}}",
		{ f(function(_, snip) return snip.captures[1] end, {}), i(1) }
	)),
	s({trig = "([%w_]+)%+%+", regTrig = true, wordTrig = false}, fmt(
		"{} = {} + 1",
		{ l(l.CAPTURE1, {}), l(l.CAPTURE1, {}) }
	)),
	s("req", fmt("local {} = require(\"{}\")", {
		dl(2, l._1:match("%.([%w_]+)$"), {1}),
		i(1)
	}))
}
