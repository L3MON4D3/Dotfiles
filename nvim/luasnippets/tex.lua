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
	return #(descr:gsub("[^clmrp]", ""))
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

local mat = function(_, snip)
	if not snip.rows then
		-- one not set -> both not set.
		snip.rows = 1
		snip.cols = 2
	end
	local nodes = {}
	local ins_indx = 1
	for j = 1, snip.rows do
		table.insert(nodes, r(ins_indx, tostring(j).."x1", i(1)) )
		ins_indx = ins_indx+1
		for k = 2, snip.cols do
			table.insert(nodes, t" & ")
			table.insert(nodes, r(ins_indx, tostring(j).."x"..tostring(k), i(1)) )
			ins_indx = ins_indx+1
		end
		table.insert(nodes, t{"\\\\", ""})
	end
	-- fix last node.
	nodes[#nodes] = t""
	return sn(nil, nodes)
end

parse_add({trig = ";"}, "\\$$1\\$$0")
s_add({trig = "(s*)sec", wordTrig = true, regTrig = true}, {
	f(function(args, snip) return {"\\"..string.rep("sub", string.len(snip.captures[1]))} end, {}),
	t({"section{"}), i(1), t({"}", ""}), i(0)
})
parse_add({trig = "beg", wordTrig = true}, "\\begin{$1}\n${2:$SELECT_DEDENT}\n\\end{$1}")
parse_add({trig = "beq", wordTrig = true}, "\\begin{equation*}\n${1:$SELECT_DEDENT}\n\\end{equation*}")
parse_add({trig = "bal", wordTrig = true}, "\\begin{aligned}\n${1:$SELECT_DEDENT}\n\\end{aligned}")
parse_add({trig = "bfr", wordTrig = true}, "\\begin{frame}\n\\frametitle{$1}\n$2\n\\end{frame}")
parse_add({trig = "ab", wordTrig = true}, "\\langle $1 \\rangle")
parse_add({trig = "lra", wordTrig = true}, "\\leftrightarrow")
parse_add({trig = "Lra", wordTrig = true}, "\\Leftrightarrow")
parse_add({trig = "fr", wordTrig = true}, "\\frac{${1:$LS_SELECT_DEDENT}}{$2}")
parse_add({trig = "tr", wordTrig = true}, "\\item $1")
parse_add({trig = "abs", wordTrig = true}, "\\lvert ${1:$SELECT_DEDENT} \\rvert")
parse_add({trig = "*", wordTrig = true}, "\\cdot ")
parse_add({trig = "sum", wordTrig = true}, [[\sum_{$1}^{$2}]])
-- parse_add({trig = "int", wordTrig = true}, [[\int_{${1:lower}}^{${2:upper}} $3 \\dx $4]])
s_add("int", fmta([[
	\int_{<>}<> <> \Intd <>
]], {
	i(1,"lower"),
	c(2, {
		t"",
		{t"^{", i(1, "upper"), t"}"}
	}),
	i(3),
	i(4)
}))
s_add("ls", {
	t({"\\begin{"}), c(1, {
		t"itemize",
		t"enumerate",
		i(nil)
	}), t({"}", "\t\\item "}),
	i(2), d(3, rec_ls, {}),
	t({"", "\\end{"}), rep(1), t"}", i(0)
})
s_add("tab", fmt([[
\begin{{tabular}}{{{}}}
{}
\end{{tabular}}
]], {i(1, "c"), d(2, tab, {1}, {
	user_args = {
		function(snip) snip.rows = snip.rows + 1 end,
		-- don't drop below one.
		function(snip) snip.rows = math.max(snip.rows - 1, 1) end
	}
} )}))
parse_add(",", [[\$$1\$]])
parse_add("it", [[\textit{$1}]])
parse_add("tx", [[\text{$1}]])
parse_add("abr", [[\langle $1 \rangle]])
parse_add("norm", [[\lVert ${1:$SELECT_DEDENT} \rVert]])
s_add({trig="mat", filetype="all"}, fmt([[
\begin{{{}}}
{}
\end{{{}}}
]], {c(1, {t"matrix", t"pmatrix", t"bmatrix", t"Bmatrix", t"vmatrix", t"Vmatrix"}),
	d(2, mat, {}, {
		user_args = {
			function(snip) snip.rows = snip.rows + 1 end,
			-- don't drop below one.
			function(snip) snip.rows = math.max(snip.rows - 1, 1) end,
			function(snip) snip.cols = snip.cols + 1 end,
			-- don't drop below one.
			function(snip) snip.cols = math.max(snip.cols - 1, 1) end
		}
	}),
	rep(1)
}))

local texpairs = {
	{"(", ")"},
	{"\\left(", "\\right)"},
	{"\\big(", "\\big)"},
	{"\\Big(", "\\Big)"},
	{"\\bigg(", "\\bigg)"},
	{"\\Bigg(", "\\Bigg)"},
}
local texsqpairs = {
	{"[", "]"},
	{"\\left[", "\\right]"},
	{"\\big[", "\\big]"},
	{"\\Big[", "\\Big]"},
	{"\\bigg[", "\\bigg]"},
	{"\\Bigg[", "\\Bigg]"},
}
local texcupairs = {
	{"{", "}"},
	{"\\{", "\\}"},
	{"\\left\\{", "\\right\\}"},
	{"\\big\\{", "\\big\\}"},
	{"\\Big\\{", "\\Big\\}"},
	{"\\bigg\\{", "\\bigg\\}"},
	{"\\Bigg\\{", "\\Bigg\\}"},
}

local function choices_from_pairlist(ji, list)
	local choices = {}
	for _, pair in ipairs(list) do
		table.insert(choices, {
			t(pair[1]), r(1, "inside_pairs", dl(1, l.LS_SELECT_DEDENT)), t(pair[2])
		})
	end
	return c(ji, choices)
end

s_add({trig = "(", wordTrig=false}, {
	choices_from_pairlist(1, texpairs)
})
s_add({trig = "[", wordTrig=false}, {
	choices_from_pairlist(1, texsqpairs)
})
s_add({trig = "{", wordTrig=false}, {
	choices_from_pairlist(1, texcupairs)
})

parse_add("comm", "\\newcommand{$1}{$2}")

parse_add({trig = ".inv", wordTrig = false}, "^{-1}")

-- s_add_auto({trig = "_", wordTrig = false}, {
-- 	t"_", c(1, {
-- 		r(1, "bot", i(1)),
-- 		{t"{", r(1, "bot", i(1)), t"}"}
-- 	})
-- })
