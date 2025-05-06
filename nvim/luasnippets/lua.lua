s_add({trig="if", wordTrig=true}, {
	t({"if "}),
	i(1),
	t({" then", "\t"}),
	isn(2, {dl(1, l.LS_SELECT_DEDENT)}, "$PARENT_INDENT\t"),
	t({"", "end"})
})
s_add({trig="ee", wordTrig=true}, {
	t({"else", "\t"}),
	i(0),
})
s_add("for", {
	t"for ", c(1, {
		sn(nil, {i(1, "k"), t", ", i(2, "v"), t" in ", c(3, {{t"pairs(",i(1),t")"}, {t"ipairs(",i(1),t")"}, i(nil)}) }),
		sn(nil, {i(1, "val"), t" in ", i(2) }),
		sn(nil, {i(1, "i"), t" = ", i(2), t", ", i(3) }),
		fmt([[{} in vim.gsplit({})]], {i(1, "str"), i(2)})
	}), t{" do", "\t"}, isn(2, {dl(1, l.LS_SELECT_DEDENT)}, "$PARENT_INDENT\t"), t{"", "end"}
})

s_add("while", fmt([[
while {} do
	{}
end
]], ins_generate()))

s_add("fn", {
	c(1, {
		fmt([[
			function{}({})
				{}
			end
		]], {
			r(1, "name", i(1)),
			r(2, "args", i(1)),
			r(3, "body", d(1, function(_, parent)
				if #parent.snippet.env.LS_SELECT_DEDENT ~= 0 then
					return isn(nil, {
						t(parent.snippet.env.LS_SELECT_DEDENT), i(1)
					}, "$PARENT_INDENT\t")
				else
					return sn(nil, { i(1) })
				end
			end))
		}),
		fmt([[function{}({}) {} end]], {
			r(1, "name"),
			r(2, "args"),
			r(3, "body")
		})
	})
})

s_add("str", fmt("[[\n\t{}\n]]", ins_generate()))
s_add("sdt", fmt(
	[[ls_helpers.static_docstring_test({}, {}, {})]],
	{ i(1, "snip"), c(2, {{t"{\"", i(1), t"\"}"}, i(1)}), c(3, {{t"{\"", i(1), t"$0\"}"}, i(1)}) } )
)
s_add("lar", fmt(
	"${{{}}}",
	{ i(1) }
))
s_add({trig = "lar(%d)", regTrig = true, wordTrig = false}, fmt(
	"${{{}:{}}}",
	{ f(function(_, snip) return snip.captures[1] end, {}), i(1) }
))
s_add({trig = "([%w_]+)%+%+", regTrig = true, wordTrig = false}, fmt(
	"{} = {} + 1",
	{ l(l.CAPTURE1, {}), l(l.CAPTURE1, {}) }
))
s_add("req", fmt("local {} = require(\"{}\")", {
	dl(2, l._1:match("%.?([%w_]+)$"), {1}),
	i(1)
}))
parse_add("ti", "table.insert($1, $2)")

parse_add_auto("tiaa", "table.insertaaa($1, $2)")

s_add("I", fmt("I({})", {c(1, {parse(nil, "{\"$1\", $2}"), i(1)})}))

local function uuid()
	local id, _ = vim.fn.system('uuidgen'):gsub('\n', '')
	return id
end

s_add("add_k", fmta([[
	ls.add_snippets("all", {
		<>
	}, { key = "<>" })
]], {
	i(1),
	f(function() return uuid() end)
}))
