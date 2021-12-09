local ls = require("luasnip")

local snip_defs = {
	s = ls.s,
	sn = ls.sn,
	t = ls.t,
	i = ls.i,
	f = ls.f,
	c = ls.c,
	d = ls.d,
	isn = require("luasnip.nodes.snippet").ISN,
	psn = require("luasnip.nodes.snippet").PSN,
	l = require'luasnip.extras'.l,
	r = require'luasnip.extras'.rep,
	p = require("luasnip.extras").partial,
	types = require("luasnip.util.types"),
	events = require("luasnip.util.events"),
	util = require("luasnip.util.util"),
	fmt = require("luasnip.extras.fmt").fmt,
}

local function setup_snip_env()
	-- change index in new metatable to first go through snip_defs and then
	-- into the original __index (not the other way around, as __index might
	-- have been a function).
	local mt = getmetatable(_G) or {}
	mt.__index = setmetatable(vim.deepcopy(snip_defs), {
		__index = mt.__index
	})
	setfenv(2, setmetatable(_G, mt))
end

local function remove_snip_env()
	-- undo modifications from setup_snip_env.
	local mt = getmetatable(_G) or {}
	mt.__index = getmetatable(mt.__index).__index
	setfenv(2, setmetatable(_G, mt))
end

return {
	setup_snip_env = setup_snip_env,
	remove_snip_env = remove_snip_env
}
