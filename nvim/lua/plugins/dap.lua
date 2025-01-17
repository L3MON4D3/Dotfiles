local dap = require('dap')

dap.defaults.fallback.external_terminal = {
	command = '/usr/bin/foot';
	-- footclient executes first argument.
	args = {'-Tfloatwindow'};
}

dap.defaults.fallback.force_external_terminal = true

dap.adapters.lldb = {
	type = 'executable',
	command = '/usr/bin/lldb-dap',
	name = "lldb",
}
dap.adapters.julia = {
	type = "server",
	port = "${port}",
	executable = {
		command = "julia",
		args = {"-J", "/home/simon/.julia/sysimages/mine1.11-dap2.so", "--startup-file=no", "-e", "using Sockets, DebugAdapter, Logging; function start_debugger(); server_port = parse(Int, ARGS[1]); server = Sockets.listen(server_port); conn = Sockets.accept(server); debugsession = DebugAdapter.DebugSession(conn); run(debugsession); close(conn); end; start_debugger();", "${port}" }
	},
	options = {
		max_retries = 1000
	}
}

vim.fn.sign_define('DapBreakpoint', {text='〇', texthl='GruvboxRed', linehl='', numhl=''})
vim.fn.sign_define('DapBreakpointCondition', {text='〇', texthl='GruvboxBlue', linehl='', numhl=''})
vim.fn.sign_define('DapStopped', {text=' ', texthl='GruvboxYellow', linehl='', numhl=''})

local dap_widgets = require("dap.ui.widgets")

local float
vim.api.nvim_create_user_command("DF", function()
	if not float then
		float = dap_widgets.centered_float(dap_widgets.frames)
	else
		float.toggle()
	end
end, {})

local sidebar
vim.api.nvim_create_user_command("DS", function()
	if not sidebar then
		sidebar = dap_widgets.sidebar(dap_widgets.scopes)
	end
	sidebar.toggle()
end, {})

vim.api.nvim_create_user_command("DT", function()
	dap.terminate();
end, {})

vim.cmd[[
command! DR :lua require("dap").repl.toggle()

noremap <F2> :lua require"dap".toggle_breakpoint()<Cr>
" S-F2
noremap <F14> :lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>
noremap <F18> :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
noremap <F3> :lua require"dap".step_over()<Cr>
noremap <F4> :lua require"dap".step_into()<Cr>
noremap <F16> :lua require"dap".step_out()<Cr>
noremap <F17> :lua require"dap".run_last()<Cr>
noremap <F6> :lua require"dap.ui.widgets".hover()<Cr>
noremap - :lua require"dap".up()<Cr>
noremap + :lua require"dap".down()<Cr>
]]


