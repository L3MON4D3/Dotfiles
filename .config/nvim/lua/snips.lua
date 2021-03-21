local ls = require'luasnip'
local s = ls.s
local sn = ls.sn
local t = ls.t
local i = ls.i
local f = ls.f
local c = ls.c
local d = ls.d

local function no(arg)
	return arg
end

local function copy(args, a1, a2)
	return args[1]
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

local function just_fn(args)
	return sn(nil, {
		t(args[1]),
		i(1),
		t({"("}),
		i(2, args[2]),
		t({") {", "\t"}),
		f(copy, {2}),
		i(0),
		t({"", "}"})
	})
end

local function neg(fn, ...)
	return not fn(...)
end

ls.snippets = {
	all = {
		s("(", { t({"("}), i(1), t({")"}), i(0) }, neg, char_count_same, '%(', '%)'),
		s("{", { t({"{"}), i(1), t({"}"}), i(0) }, neg, char_count_same, '%{', '%}'),
		s("[", { t({"["}), i(1), t({"]"}), i(0) }, neg, char_count_same, '%[', '%]') ,
		s("<", { t({"<"}), i(1), t({">"}), i(0) }, neg, char_count_same, '<', '>'),
		s("'", { t({"'"}), i(1), t({"'"}), i(0) }, neg, even_count, '\''),
		s("\"", { t({"\""}), i(1), t({"\""}), i(0) }, neg, even_count, '"'),
		s("{+", { t({"{","\t"}), i(1), t({"", "}"}), i(0) }),
		s("fn", {
			t({"//Parameters: "}),
			f(copy, {2}),
			t({"", "function "}),
			i(1),
			t({"("}),
			i(2, {"int foo"}),
			t({") {", "\t"}),
			i(0),
			t({"", "}"})
		}),
		s("test1", {
			i(1),
			t({"lol"}),
			sn(2, {
				t({"function "}),
				i(1),
				t({"("}),
				i(2, {"int foo"}),
				t({") {", "\t"}),
				f(copy, {2}),
				i(0),
				t({"", "}"})
			}),
			t({"lal"}),
			i(3),
			t({"asdf"}),
			i(0)
		}),
		s("ctest", {
			t({"lel "}),
			i(1),
			c(2, {
				sn(nil, {
					t({"function "}),
					i(1),
					t({"("}),
					i(2, {"int foo"}),
					t({") {", "\t"}),
					f(copy, {2}),
					i(0),
					t({"", "}"})
				}),
				t({"2"}),
				t({"3"}),
			}),
			i(0)
		}),
		s("class", {
			c(1, {
				t({"public "}),
				t({"private "})
			}),
			t({"class "}),
			i(2),
			t({" "}),
			c(3, {
				t({"{"}),
				sn(nil, {
					t({"extends "}),
					i(0),
					t({" {"})
				}),
				sn(nil, {
					t({"implements "}),
					i(0),
					t({" {"})
				})
			}),
			t({"","\t"}),
			i(0),
			t({"", "}"})
		}),
		s("dtest", {
			i(1),
			t({"aaa "}),
			i(2),
			t({"bbb"}),
			d(3, just_fn, {1, 2}),
			t({" ccc "}),
			i(0)
		})
	},
	sh = {
		s("test2", {t({"SUCCESS"}), i(0)})
	}
}
