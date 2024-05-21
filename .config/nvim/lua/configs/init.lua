local autotable = require("auto_table").autotable
local make_config = require("configs.make_config")
local util = require("util")
local gen_config = require("configs.gen_config")
local config_picker = require("configs.config_picker")

local M = {}

local global_config_fname
local global_config

local function gen_global_config()
	local config_t = loadfile(global_config_fname)()
	global_config = gen_config(global_config_fname, config_t)
end

-- index as buf_configs[bufnr][bufname]
local buf_configs = autotable(2)

-- args: must contain args.buf, the bufnr, and args.file, the filename.
local function load_config(args)
	if buf_configs[args.buf][args.file] then
		-- already executed for this buffer, do nothing.
		return
	end

	local bufnr = args.buf
	local bufname = args.file
	local f_conf = buf_configs[bufnr][bufname]
	if not f_conf then
		f_conf = make_config(bufnr, global_config)
		buf_configs[bufnr][bufname] = f_conf
	end

	f_conf:apply(args)
end

function M.setup(fname)
	global_config_fname = fname
	gen_global_config()

	vim.api.nvim_create_autocmd({"BufEnter"}, {
		-- to run under all circumstances I guess?
		callback = load_config
	})
	vim.api.nvim_create_user_command("C", function()
		require("configs.config_picker").pick_current()
	end, {})
	vim.api.nvim_create_autocmd({"BufWritePost"}, {
		-- to run under all circumstances I guess?
		callback = M.reset,
		pattern = fname
	})
end

function Config(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local bufname = vim.api.nvim_buf_get_name(bufnr)

	local conf = buf_configs[bufnr][bufname]
	if conf then
		return conf
	end
	error(("Config not generated for bufnr %s (file %s)"):format(bufnr, bufname))
end

local function load_open_bufs()
	for _, bufnr in pairs(util.get_loaded_bufs()) do
		load_config({ buf = bufnr, file = vim.api.nvim_buf_get_name(bufnr) })
	end
end

function M.reset()
	for bufnr, nr_configs in pairs(buf_configs) do
		for _, config in pairs(nr_configs) do
			if vim.api.nvim_buf_is_loaded(bufnr) then
				-- only undo for valid buffers.
				config:undo(bufnr)
			end
		end
	end

	config_picker.reset(global_config_fname)

	-- re-generate global configuration.
	gen_global_config()
	-- clear loaded configs.
	buf_configs = autotable(2)
	load_open_bufs()
end

return M
