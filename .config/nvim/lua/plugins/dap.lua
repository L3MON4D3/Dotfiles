local dap = require('dap')

local function pdofile(name)
	local module_found, res = pcall(dofile, name)
	return module_found and res or {}
end

dap.defaults.fallback.external_terminal = {
	command = '/usr/bin/foot';
	-- footclient executes first argument.
	args = {'-Tfloatwindow'};
}

dap.defaults.fallback.force_external_terminal = true

dap.adapters.lldb = {
	type = 'executable',
	command = '/usr/bin/lldb-vscode',
	name = "lldb",
}

dap.adapters.cppdbg = {
	type = 'executable',
	command = '/usr/lib/nvim-dap-cpptools/debugAdapters/OpenDebugAD7',
	name = "vscode-cpptools",
}
dap.set_log_level("DEBUG")

vim.fn.sign_define('DapBreakpoint', {text='⛔', texthl='GruvboxRed', linehl='', numhl=''})
vim.fn.sign_define('DapStopped', {text=' ', texthl='GruvboxYellow', linehl='', numhl=''})

dap.configurations.cpp = {
	{
		name = "Launch",
		type = "lldb",
		request = "launch",
		program = function()
			return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
		end,
		cwd = '${workspaceFolder}',
		stopOnEntry = false,
	},
	{
		name = "Attach",
		type = "lldb",
		request = "attach",
		cwd = '${workspaceFolder}',
		pid = require('dap.utils').pick_process,
		stopOnEntry = false,
		args = {},
	},
	unpack(pdofile(".nvim_local.lua").dap or {})
}
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

local widget_entities = {
	scopes = "s",
	frames = "f",
	-- expression = "e"
}

local widget_views = {
	sidebar = "s",
	centered_float = "f",
}

dap_widgets = {}
local widgets = require("dap.ui.widgets")

for e_k, e_v in pairs(widget_entities) do
	dap_widgets[e_k] = {}
	for v_k, v_v in pairs(widget_views) do
		local widget = widgets[v_k](widgets[e_k])
		-- is opened in constructor :\
		widget.close()
		dap_widgets[e_k][v_k] = widget

		-- eg. <leader>dsf
		vim.api.nvim_set_keymap("n",
			",d"..e_v..v_v,
			"<cmd>lua dap_widgets."..e_k.."."..v_k..".toggle()<Cr>",
			{noremap=true, silent = true})
	end
end

