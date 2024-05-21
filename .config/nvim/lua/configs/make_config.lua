local Config_t = require("configs.config_new")

local function gen_configs_from_patterns(buf, bufname, configs)
	-- use cwd if buffer for initial buffer (I guess fname == "" is the only
	-- way to detect that one).
	if bufname == "" then
		bufname = vim.loop.cwd()
	end

	local pattern_configs = {dir = {}, filetype = {}, file = {}}
	for pattern, config in pairs(configs.pattern) do
		local match = bufname:match(pattern)
		if match then
			if pattern_configs[config.category][match] then
				-- the order in which we force does not matter (for now), the
				-- only guarantee regarding priority is that file overrides
				-- dir overrides filetype.
				pattern_configs[config.category][match] = pattern_configs[config.category][match]:_append(config)
			else
				pattern_configs[config.category][match] = config
			end
		end
	end

	return pattern_configs
end

-- return list of configs, with least specific at [1], most specific at [#t].
local function dir_configs_sorted(buf, bufname, pattern_configs, configs, cwd)
	local path_so_far = ""
	local matching_configs = {}

	for _, path_component in ipairs(vim.split(cwd, "/", {plain=true})) do
		path_so_far = path_so_far .. path_component
		-- important: insert the pattern-generated config before the one that
		-- is exactly meant for this directory.
		-- Makes more sense priority-wise.
		table.insert(matching_configs, pattern_configs.dir[path_so_far])

		if configs.dir[path_so_far] then
			table.insert(matching_configs, configs.dir[path_so_far])
		end

		path_so_far = path_so_far .. "/"
	end

	return matching_configs
end

-- generate filetype-configs:
-- first filetypes from global configs, the earlier a ft in the comma-separated
-- enumeration, the higher its priority, eg the later it appears in the
-- returned list.
-- Also, all filetype-configs from global config are higher-priority than those
-- of the pattern-config.
local function filetype_configs_sorted(buf, bufname, pattern_configs, configs, filetype_string)
	local fts_reversed = {}
	for _, ft in ipairs(vim.split(filetype_string, ",", {plain=true})) do
		table.insert(fts_reversed, 1, ft)
	end

	local matching_configs = {}
	for _, ft in ipairs(fts_reversed) do
		table.insert(matching_configs, pattern_configs.filetype[ft])
	end
	for _, ft in ipairs(fts_reversed) do
		if configs.filetype[ft] then
			table.insert(matching_configs, configs.filetype[ft])
		end
	end
	return matching_configs
end

local function bufname_to_dir(bufname)
	if bufname == "" then
		return vim.loop.cwd()
	end
	if bufname:sub(1, 11) == "fugitive://" then
		-- filename is like fugitive://<.git-directory-with-trailing-slash>/
		-- omit appended / and fugitive://
		return bufname:sub(12, -2)
	end
	return vim.fn.fnamemodify(bufname, ":h")
end

-- generate config for buffer by
-- * finding all applicable configs in `configs`
-- * merging them, with more specific configs overriding/extending those more
--   general ones.
--   The exact order, by ascending priority, is
--   * dir
--   * filetype
--   * filename
--   The priority inside these categories is described further in their
--   respective functions/in this function.
local function gen_buf_config(buf, global_configs)
	local bufname = vim.api.nvim_buf_get_name(buf)
	local buf_dir = bufname_to_dir(bufname)

	local matching_configs = {}
	for _, configs in ipairs(global_configs) do
		-- generate configs from patterns.
		local pattern_configs = gen_configs_from_patterns(buf, bufname, configs)

		-- lowest prio: filetype-config.
		vim.list_extend(matching_configs, filetype_configs_sorted(buf, bufname, pattern_configs, configs, vim.bo[buf].filetype))

		-- next lowest priority: directory-configs, sorted by adjacency to buffer-file.
		vim.list_extend(matching_configs, dir_configs_sorted(buf, bufname, pattern_configs, configs, buf_dir))

		-- finally: file-config. Since the buffer only has one file, we just insert those in this function.
		table.insert(matching_configs, pattern_configs.file[bufname])

		if configs.file[bufname] then
			table.insert(matching_configs, configs.file[bufname])
		end
	end

	local config = Config_t.new({})
	for _, app_conf in ipairs(matching_configs) do
		config:append(app_conf)
	end

	return config
end

return gen_buf_config
