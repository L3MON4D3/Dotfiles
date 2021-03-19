local ls = require'luasnip'
local s = ls.s
local t = ls.t
local i = ls.i
local f = ls.f

local function no(arg)
	return arg
end

local function copy(args, a1, a2)
	return {a1, a2}
end

local function char_count_same(c1, c2)
	local line = vim.api.nvim_get_current_line()
	local _, ct1 = string.gsub(line, c1, '')
	local _, ct2 = string.gsub(line, c2, '')
	return ct1 == ct2
end

local function even_count(c)
	local line = vim.api.nvim_get_current_line()
	local _, ct = string.gsub(line, c, '')
	return ct % 2 == 0
end

local function neg(fn, ...)
	return not fn(...)
end

ls.snippets = {
	s("(", { t({"("}), i(1), t({")"}), i(0) }, neg, char_count_same, '%(', '%)'),
	s("{", { t({"{"}), i(1), t({"}"}), i(0) }, neg, char_count_same, '%{', '%}'),
	s("[", { t({"["}), i(1), t({"]"}), i(0) }, neg, char_count_same, '%[', '%]') ,
	s("<", { t({"<"}), i(1), t({">"}), i(0) }, neg, char_count_same, '<', '>'),
	s("'", { t({"'"}), i(1), t({"'"}), i(0) }, neg, even_count, '\''),
	s("\"", { t({"\""}), i(1), t({"\""}), i(0) }, neg, even_count, '"'),
	s("{+", { t({"{","\t"}), i(1), t({"", "}"}), i(0) }),
	s("fn", {
		t({"function "}),
		i(1),
		t({"("}),
		i(2, {"int foo"}),
		t({") {", "\t"}),
		f(copy, {2}),
		i(0),
		t({"", "}"})
	})
}