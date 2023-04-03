local options = require("configs.config_options")

local M = {}

local complete_conf_mt = {
	__index = vim.tbl_map(function(option)
		return option.default
	end, options)
}

local combine_strategies = vim.tbl_map(function(option)
	return option.combine_strategy
end, options)

-- combine such that early values are overridden by later ones.
-- (like vim.tbl_merge with "force").
function M.combine_force(...)
	local combined = {}

	local configs = {...}

	-- turn {{a=1, b="b"}, {a=2, b="c"}, {a=3, b="e"}}
	-- into {a={1,2,3}, b={"b", "c", "e"}}
	-- (some kind of transpose I guess)
	local key_lists = {}
	for key, _ in pairs(options) do
		key_lists[key] = {}
	end
	for _, c in ipairs(configs) do
		for key, _ in pairs(options) do
			table.insert(key_lists[key], c[key])
		end
	end

	-- now create combined config from collected key-lists.
	for key, strategy in pairs(combine_strategies) do
		combined[key] = strategy(key_lists[key])
	end

	return combined
end

-- complete config, so it has keys dap,run_buf,run_session, and functions are
-- only executed once in buffer or session.
local function new(o)
	for key, option in pairs(options) do
		o[key] = option.finalize(o[key])
	end

	return setmetatable(o, complete_conf_mt)
end

local id = function(k) return k end
local keymod = {
	dir = function(k)
		if not k:match("/$") then
			return k .. "/"
		else
			return k
		end
	end,
	pattern = id,
	filetype = id,
	file = id,
}

function M.gen_config(conf)
	local generated_configs = {}

	for _, config in ipairs(conf) do
		local generated_config = {
			dir = {},
			pattern = {},
			filetype = {},
			file = {}
		}
		for category, t in pairs(config) do
			for k, v in pairs(t) do
				-- process configs:
				-- make sure some functions are only run once in some buffer, or session.
				generated_config[category][keymod[category](k)] = new(v)
			end
		end
		table.insert(generated_configs, generated_config)
	end
	return generated_configs
end

return M
