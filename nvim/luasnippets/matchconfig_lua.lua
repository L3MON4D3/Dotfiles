parse_add_auto("MC", "Matchconfig.")
s_add("lvi", fmt([[
	require("matchconfig.util.log").new("temp").error({})
]], {
	c(1, {
		parse(nil, [["$1"]]),
		parse(nil, [["$1" .. vim.inspect({$1})]]),
		t"debug.traceback()",
	})
}))
