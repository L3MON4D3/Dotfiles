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
