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


local function column_count_from_string(descr)
	return #(descr:gsub("[^clm]", ""))
end

local tab = function(args, snip)
	local cols = column_count_from_string(args[1][1])
	if not snip.rows then
		snip.rows = 1
	end
	local nodes = {}
	local ins_indx = 1
	for j = 1, snip.rows do
		table.insert(nodes, r(ins_indx, tostring(j).."x1", i(1)))
		ins_indx = ins_indx+1
		for k = 2, cols do
			table.insert(nodes, t" & ")
			table.insert(nodes, r(ins_indx, tostring(j).."x"..tostring(k), i(1)))
			ins_indx = ins_indx+1
		end
		table.insert(nodes, t{"\\\\", ""})
	end
	-- fix last node.
	nodes[#nodes] = t""
	return sn(nil, nodes)
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
	}),
	s("tab", fmt([[
	\begin{{tabular}}{{{}}}
	{}
	\end{{tabular}}
	]], {i(1, "c"), d(2, tab, {1},
		function(snip) snip.rows = snip.rows + 1 end,
		-- don't drop below one.
		function(snip) snip.rows = math.max(snip.rows - 1, 1) end)}))
}
