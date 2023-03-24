local conf = require("configs.config")
local configs = conf.gen_config(require("configs.configs"))

-- define globally for access anywhere.
local function gen_file_config(fname)
	-- find configs where pattern matches fname, and apply those higher up in
	-- the path before those lower down.
	local path_to_config = {}
	local paths = {}

	for pattern, config in pairs(configs) do
		local match = fname:match("^"..pattern)
		if match then
			path_to_config[match] = config
			table.insert(paths, match)
		end
	end

	-- sort such that short paths occur before longer ones.
	-- Then, configs from less specific paths are overridden with those of more
	-- specific ones.
	table.sort(paths, function(sort_before, sort_after)
		return #sort_before < #sort_after
	end)

	local sorted_configs = vim.tbl_map(function(path)
		return path_to_config[path]
	end, paths)

	return conf.combine_force(unpack(sorted_configs))
end

local generated_confs = {}
function Config(bufnr)
	local fname = vim.api.nvim_buf_get_name(bufnr)
	if fname == "" then
		fname = vim.loop.cwd()
	end

	local f_conf = generated_confs[fname]
	if not f_conf then
		f_conf = gen_file_config(fname)
		generated_confs[fname] = f_conf
	end

	return f_conf
end

local function fileconfig_au_cb(args)
	Config(args.buf).run_buf(args)
	Config(args.buf).run_session()
end
vim.api.nvim_create_autocmd({"BufRead","BufNewFile"}, {
	-- to run under all circumstances I guess?
	callback = fileconfig_au_cb
})

fileconfig_au_cb({buf = 0})
