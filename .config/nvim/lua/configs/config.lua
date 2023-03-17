local M = {}

local nop = function() end

local complete_conf_mt = {
	__index = {
		dap = {},
		run_buf = nop,
		run_session = nop,
		luasnip_ft_extend = {}
	}
}

-- create function calling all passed functions in passed order.
-- functions: list of functions
local function fn_combine(functions)
	return function(bufnr)
		for _, fn in ipairs(functions) do
			fn(bufnr)
		end
	end
end

local combine_strategies = {
	-- only handles flat lists of cpp-configurations, extend in future.
	-- daps: list of cpp-configurations
	dap = function(daps)
		local combined = {}

		for _, dap_config in ipairs(daps) do
			vim.list_extend(combined, dap_config)
		end

		return combined
	end,
	run_buf = fn_combine,
	run_session = fn_combine,
	luasnip_ft_extend = function(ft_extensions)
		local merged = {}
		for _, ft_extend in ipairs(ft_extensions) do
			for ft, extensions in pairs(ft_extend) do
				if not merged[ft] then
					merged[ft] = extensions
				else
					vim.list_extend(merged[ft], extensions)
				end
			end
		end

		return merged
	end
}

-- combine such that early values are overridden by later ones.
-- (like vim.tbl_merge with "force").
function M.combine_force(...)
	local combined = {}

	local configs = {...}

	-- turn {{a=1, b="b"}, {a=2, b="c"}, {a=3, b="e"}}
	-- into {a={1,2,3}, b={"b", "c", "e"}}
	-- (some kind of transpose I guess)
	local key_items = {}
	for key, _ in pairs(combine_strategies) do
		key_items[key] = {}
	end
	for _, c in ipairs(configs) do
		for key, _ in pairs(combine_strategies) do
			table.insert(key_items[key], c[key])
		end
	end

	-- now create combined config from collected key-lists.
	for key, strategy in pairs(combine_strategies) do
		combined[key] = strategy(key_items[key])
	end

	return combined
end

local auto_table_mt = {
	__index = function(t, k)
		local v = {}
		rawset(t, k, v)
		return v
	end
}
local buf_run_fns = setmetatable({}, auto_table_mt)
local session_run_fns = {}

-- complete config, so it has keys dap,run_buf,run_session, and functions are
-- only executed once in buffer or session.
local function new(o)
	if o.run_buf then
		local old_buf_func = o.run_buf
		o.run_buf = function(args)
			-- only run buf_func if it wasn't run already.
			if buf_run_fns[args.buf][old_buf_func] == nil then
				old_buf_func(args)
				buf_run_fns[args.buf][old_buf_func] = true
			end
		end
	end

	if o.run_session then
		local old_session_func = o.run_session
		o.run_session = function()
			if session_run_fns[old_session_func] == nil then
				old_session_func()
				session_run_fns[old_session_func] = true
			end
		end
	end

	return setmetatable(o, complete_conf_mt)
end

function M.gen_config(conf)
	for k, v in pairs(conf) do
		-- process configs:
		-- make sure some functions are only run once in some buffer, or session.
		conf[k] = new(v)
	end
	return conf
end

return M
