-- parse_add({trig = "if", wordTrig = true}, "if ($1)\n\t${LS_SELECT_DEDENT}$0")
s_add({trig = "for(%w+)", wordTrig = true, regTrig = true}, fmt([[
	for ({}; {}; {})
		{}
]], {
	dl(1, "int " .. l.CAPTURE1 .. " = 0", {}),
	c(2, {sn(nil, {l(l.CAPTURE1), t({" != "}), i(1)}), i(nil)}),
	dl(3, "++" .. l.CAPTURE1, {}),
	i(0)
}))


s_add("if", fmt([[
	if ({}) {brackets_open}
		{content}
	{brackets_close}
]], {
	[1] = i(1),
	content = d(2, function(_, parent)
		if #parent.snippet.env.LS_SELECT_DEDENT ~= 0 then
			return isn(nil, {
				t(parent.snippet.env.LS_SELECT_DEDENT), i(1)
			}, "$PARENT_INDENT\t")
		else
			return sn(nil, { i(1) })
		end
	end),
	brackets_open = f(function(args)
		if #args[1] > 1 then
			return "{"
		end
	end, 2),
	brackets_close = f(function(args)
		if #args[1] > 1 then
			return "}"
		end
	end, 2)
}))

ts_px_add({
		trig = ".ei",
		matchTSNode = {
			query = "(if_statement) @prefix",
			query_lang = "c",
			select = "longest"
		},
		reparseBuffer = "live" }, {
		d(1, function(_, parent)
			if parent.env.LS_TSMATCH == nil then
				return s(nil, t"")
			end
			-- tricky: remove indent on lines containing LS_TSMATCH. The
			-- indentation is provided by the captured `if`.
			return sn(nil, {
				isn(1, fmt([[
					{} else if ({}) {{]], {t(parent.env.LS_TSMATCH), i(1)}), ""),
				t{"",""},
				sn(2, fmt([[
						{}
					}}
				]], {i(1)})) })
		end)})
