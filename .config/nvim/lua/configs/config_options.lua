local nop = function() end
local id = function(x) return x end

local applied_buf = require("auto_table").autotable(3)
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
			local config_set = {}

			for _, dap_configs in ipairs(daps) do
				for _, config in ipairs(dap_configs) do
					-- collect one per my_type.
					config_set[config.my_type] = config
				end
			end

			local config_list = {}
			for _, v in pairs(config_set) do
				table.insert(config_list, v)
			end

			return config_list
		end,
		finalize = id,
		apply = function(v, args)
			local dap = require("dap")

			vim.keymap.set("n", "<F5>", function()
				if dap.session() then
					-- session active, just do regular continue.
					dap.continue()
					return
				end

				-- otherwise, open picker to select from possible configs.
				require("dap.ui").pick_if_many(
					v,
					"Configuration: ",
					function(i) return i.name end,
					function(configuration)
						if configuration then
							vim.notify('Running configuration ' .. configuration.name, vim.log.levels.INFO, {title = "DAP"})
							dap.run(configuration)
						else
							vim.notify('No configuration selected', vim.log.levels.INFO, {title = "DAP"})
						end
					end
				)
			end, { buffer = args.buf} )
		end
	},
	run_buf = {
		default = nop,
		combine_strategy = fn_combine,
		finalize = function(run_buf)
			if run_buf then
				return function(args)
					-- only run buf_func if it wasn't run already.
					-- Track via buf-number and filename, since the file may
					-- change for initial buffers ("[None]").
					if not applied_buf[args.buf][args.file][run_buf] then
						run_buf(args)
						applied_buf[args.buf][args.file][run_buf] = true
					end
				end
			end
		end,
		apply = function(v, args) v(args) end
	},
	run_session = {
		default = nop,
		combine_strategy = fn_combine,
		-- prevent running the same session-function twice.
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
	-- for patterns!!
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
