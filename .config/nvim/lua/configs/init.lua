local conf = require("configs.config")
local configs = conf.gen_config(require("configs.configs"))
local config_options = require("configs.config_options")

local function gen_configs_from_patterns(fname)
	-- use cwd if buffer for initial buffer (I guess fname == "" is the only
	-- way to detect that one).
	if fname == "" then
		fname = vim.loop.cwd()
	end

	local pattern_configs = {dir = {}, filetype = {}, file = {}}
	for pattern, config in pairs(configs.pattern) do
		local match = fname:match(pattern)
		if match then
			pattern_configs[config.category][match] = config
		end
	end

	return pattern_configs
end

-- return list of configs, with least specific at [1], most specific at [#t].
local function dir_configs_sorted(pattern_configs, cwd)
	local path_so_far = ""
	local matching_configs = {}

	for _, path_component in ipairs(vim.split(cwd, "/", {plain=true})) do
		path_so_far = path_so_far .. path_component .. "/"
		-- important: insert the pattern-generated config before the one that
		-- is exactly meant for this directory.
		-- Makes more sense priority-wise.
		table.insert(matching_configs, pattern_configs.dir[path_so_far])
		table.insert(matching_configs, configs.dir[path_so_far])
	end

	return matching_configs
end

-- generate filetype-configs:
-- first filetypes from global configs, the earlier a ft in the comma-separated
-- enumeration, the higher its priority, eg the later it appears in the
-- returned list.
-- Also, all filetype-configs from global config are higher-priority than those
-- of the pattern-config.
local function filetype_configs_sorted(pattern_configs, filetype_string)
	local fts_reversed = {}
	for _, ft in ipairs(vim.split(filetype_string, ",", {plain=true})) do
		table.insert(fts_reversed, 1, ft)
	end

	local matching_configs = {}
	for _, ft in ipairs(fts_reversed) do
		table.insert(matching_configs, pattern_configs.filetype[ft])
	end
	for _, ft in ipairs(fts_reversed) do
		table.insert(matching_configs, configs.filetype[ft])
	end
	return matching_configs
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
local function gen_buf_config(buf)
	local bufname = vim.api.nvim_buf_get_name(buf)

	-- generate configs from patterns.
	local pattern_configs = gen_configs_from_patterns(bufname)

	local matching_configs = {}

	-- lowest priority: directory-configs.
	local buf_dir = bufname ~= "" and vim.fn.fnamemodify(bufname, ":h") or vim.loop.cwd()
	vim.list_extend(matching_configs, dir_configs_sorted(pattern_configs, buf_dir))
	-- next: filetype-config.
	vim.list_extend(matching_configs, filetype_configs_sorted(pattern_configs, vim.bo[buf].filetype))
	-- finally: file-config. Since the buffer only has one file, we just insert those in this function.
	table.insert(matching_configs, pattern_configs.file[bufname])
	table.insert(matching_configs, configs.file[bufname])

	return conf.combine_force(unpack(matching_configs))
end

local generated_confs = {}
function Config(bufnr)
	local f_conf = generated_confs[bufnr]
	if not f_conf then
		f_conf = gen_buf_config(bufnr)
		generated_confs[bufnr] = f_conf
	end

	return f_conf
end

local function fileconfig_au_cb(args)
	for k, k_apply in pairs(vim.tbl_map(function(option) return option.apply end, config_options)) do
		k_apply(Config(args.buf)[k], args)
	end
end
vim.api.nvim_create_autocmd({"BufEnter","BufNewFile"}, {
	-- to run under all circumstances I guess?
	callback = fileconfig_au_cb
})
