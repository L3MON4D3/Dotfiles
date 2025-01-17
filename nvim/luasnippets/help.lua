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

s_add({trig="con", wordTrig=true}, {
	i(1),
	f(function(args) return {" "..string.rep(".", 80-(#args[1][1]+#args[2][1]+2+2)).." "} end, {1, 2}),
	t({"|"}),
	i(2),
	t({"|"}),
	i(0)
})
s_add({trig="*", wordTrig=true}, {
	t({"*"}),
	i(1),
	t({"*"}),
	i(0)
}, { cond = part(neg, even_count, '%*') })
