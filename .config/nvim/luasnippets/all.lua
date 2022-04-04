local function neg(fn, ...)
	return not fn(...)
end

local function even_count(c)
	local line = vim.api.nvim_get_current_line()
	local _, ct = string.gsub(line, c, '')
	return ct % 2 == 0
end

local function part(func, ...)
	local args = {...}
	return function() return func(unpack(args)) end
end

local function char_count_same(c1, c2)
	local line = vim.api.nvim_get_current_line()
	local _, ct1 = string.gsub(line, '%'..c1, '')
	local _, ct2 = string.gsub(line, '%'..c2, '')
	return ct1 == ct2
end

local function pair(pair_begin, pair_end, expand_func, ...)
	return s({trig = pair_begin, wordTrig=false}, {t({pair_begin}), i(1), t({pair_end})}, {condition = part(expand_func, part(..., pair_begin, pair_end))})
end

return {
	pair("(", ")", neg, char_count_same),
	pair("{", "}", neg, char_count_same),
	pair("[", "]", neg, char_count_same),
	pair("<", ">", neg, char_count_same),
	pair("'", "'", neg, even_count),
	pair('"', '"', neg, even_count),
	pair("`", "`", neg, even_count),
	s({trig="{,", wordTrig=false, hidden=true}, { t({"{","\t"}), i(1), t({"", "}"}) }),
	parse("lel", "lo")
}
