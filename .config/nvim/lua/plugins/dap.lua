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

vim.fn.sign_define('DapBreakpoint', {text='⛔', texthl='GruvboxRed', linehl='', numhl=''})
vim.fn.sign_define('DapBreakpointCondition', {text='⛔', texthl='GruvboxBlue', linehl='', numhl=''})
vim.fn.sign_define('DapStopped', {text=' ', texthl='GruvboxYellow', linehl='', numhl=''})

dap.configurations.cpp = vim.list_extend({
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
		}
	},
	pdofile(".nvim_local.lua").dap or {} )

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

local widget_entities = {
	scopes = "Scope",
	frames = "Frame",
	-- expression = "e"
}

local widget_views = {
	sidebar = "Sidebar",
	centered_float = "Float",
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
		vim.cmd(string.format([[command! Dap%s%s :lua dap_widgets.%s.%s.toggle()]], e_v, v_v, e_k, v_k))
	end
end

vim.cmd[[
command! DapREPL :lua require("dap").repl.toggle()

noremap <F2> :lua require"dap".toggle_breakpoint()<Cr>
" S-F2
noremap <F14> :lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>
noremap <F18> :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
noremap <F3> :lua require"dap".step_over()<Cr>
noremap <F4> :lua require"dap".step_into()<Cr>
noremap <F16> :lua require"dap".step_out()<Cr>
noremap <F5> :lua require"dap".continue()<Cr>
noremap <F17> :lua require"dap".run_last()<Cr>
noremap <F6> :lua require"dap.ui.widgets".hover()<Cr>
noremap <leader>dws :lua require"dapui".open("sidebar")<Cr>
]]
