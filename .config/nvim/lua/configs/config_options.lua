local nop = function() end
local id = function(x) return x end

local auto_table_mt = {
	__index = function(t, k)
		local v = {}
		rawset(t, k, v)
		return v
	end
}
local applied_buf = setmetatable({}, auto_table_mt)
local applied = {}

-- create function calling all passed functions in passed order.
-- functions: list of functions
local function fn_combine(functions)
	return function(bufnr)
		for _, fn in ipairs(functions) do
			fn(bufnr)
		end
	end
end

return {
	dap = {
		default = {},
		combine_strategy = function(daps)
			local combined = {}

			for _, dap_config in ipairs(daps) do
				for ft, configs in pairs(dap_config) do
					if not combined[ft] then
						combined[ft] = {}
					end
					vim.list_extend(combined[ft], configs)
				end
			end

			return combined
		end,
		finalize = id,
		apply = function(v, _)
			local dap = require("dap")

			for ft, ft_config in pairs(v) do
				if not dap.configurations[ft] then
					dap.configurations[ft] = {}
				end
				for _, config in ipairs(ft_config) do
					local config_names = vim.tbl_map(function(c) return c.name end, dap.configurations[ft])
					if not vim.tbl_contains(config_names, config.name) then
						table.insert(dap.configurations[ft], config)
					end
				end
			end
		end
	},
	run_buf = {
		default = nop,
		combine_strategy = fn_combine,
		finalize = function(run_buf)
			if run_buf then
				return function(args)
					-- only run buf_func if it wasn't run already.
					if applied_buf[args.buf][run_buf] == nil then
						run_buf(args)
						applied_buf[args.buf][run_buf] = true
					end
				end
			end
		end,
		apply = function(v, args) v(args) end
	},
	run_session = {
		default = nop,
		combine_strategy = fn_combine,
		finalize = function(run_session)
			if run_session then
				return function()
					if applied[run_session] == nil then
						run_session()
						applied[run_session] = true
					end
				end
			end
		end,
		apply = function(v, args) v(args) end
	},
	luasnip_ft_extend = {
		default = {},
		combine_strategy = function(ft_extensions)
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
		end,
		finalize = id,
		-- only exists to be queried.
		apply = nop
	},
	category = {
		default = nil,
		combine_strategy = function(categories)
			-- return last category, keep with force-combine.
			return categories[#categories]
		end,
		finalize = id,
		-- apply won't be called IIRC.
		apply = nop
	}
}
