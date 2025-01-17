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
	s_add({trig = pair_begin, wordTrig=false}, {t({pair_begin}), i(1), t({pair_end})}, {condition = part(expand_func, part(..., pair_begin, pair_end))})
end

pair("(", ")", neg, char_count_same)
pair("{", "}", neg, char_count_same)
pair("[", "]", neg, char_count_same)
pair("<", ">", neg, char_count_same)
pair("'", "'", neg, even_count)
pair('"', '"', neg, even_count)
pair("`", "`", neg, even_count)
s_add({trig="{,", wordTrig=false, hidden=true, priority=1001}, { t({"{","\t"}), i(1, "", {key = "asdf"}), t({"", "}"}) })

parse_add("lel", "lo")
parse_add("lal", "la")

-- local k = require("luasnip.nodes.key_indexer").new_key
-- s_add("aaa", {
-- 	rep(k("a")),
-- 	t" ",
-- 	i(1, "etest", {key = "a"})
-- })

s_add('map1',
    fmt(
        [[
    vim.keaeeeeeee.set('{}', '{}', function()
        {}
    end, {{ silent = true, desc = '{}' }})
    ]],
        {
            i(1, 'mode'),
            i(2, 'lhs'),
            i(3, 'vim.opt.textwidth = 100'),
            i(4, 'My awesome mapping'),
        }
    ))

parse_add("xx", "(${1:asdf})")
