local function context_nodes(idx)
	return c(idx, {
		{t'"', r(1, "trig", i(1)), t'"'},
		{t'{ trig="', r(1, "trig", i(1)), t'"', i(2), t" }"}
	})
end

local function string_nodes(idx)
	return c(idx, {
		{t'"', r(1, "content", i(1)), t'"'},
		{t{'[[', '\t'}, r(1, "content", i(1)), t{'',']]'}}
	})
end

s_add("pa", fmt([[
	parse_add({}, {})
]], {
	context_nodes(1),
	string_nodes(2)
}))

s_add("a", fmta([=[
	s_add(<>, fmta(<>, {
		<>
	}))
]=], {
	context_nodes(1),
	string_nodes(2),
	i(3)
}))
