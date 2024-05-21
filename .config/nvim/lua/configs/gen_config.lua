local yes = function(_) return true end
local key_valid = {
	dir = function(k)
		if k:match("%/$") then
			vim.notify(("dirname %s is terminated by a `/` and won't be recognized."), vim.log.levels.WARN)
			return false
		end
		return true
	end,
	pattern = yes,
	filetype = yes,
	file = yes,
}

return function(fname, conf)
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
				if key_valid[category](k) then
					generated_config[category][k] = v
					v:set_source(fname, category, k)
				end
			end
		end

		table.insert(generated_configs, generated_config)
	end

	return generated_configs
end
