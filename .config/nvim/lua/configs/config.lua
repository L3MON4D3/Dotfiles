local complete_conf = {
	__index = {
		dap = {},
		run = function() end,
		run_file = function() end
	}
}
-- complete config, so it has keys dap,run.
local function new(o)
	return setmetatable(o, complete_conf)
end

-- provide missing configs.
local complete_configs = {
	__index = function(t,k)
		local l = new({})
		rawset(t,k,l)
		return l
	end,
}

local M = {}
function M.gen_config(conf)
	for k, v in pairs(conf) do

		if k:find("/$") then
			print("config-key ends with /. Bad!")
		end
		conf[k] = new(v)
	end
	return setmetatable(conf, complete_configs)
end

return M
