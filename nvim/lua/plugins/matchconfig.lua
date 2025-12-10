local mc = require("matchconfig")
mc.setup({
	path = "configs.lua",
	options = {
		require("my_mc.options.repl"),
		{
			new = function(conf)
				return require("matchconfig.options.run_buf").new(conf, {raw_key = "run_buf_prio", respect_barrier = false})
			end,
			reset = function() end
		},
		require("matchconfig.options.bufvar"),
		require("matchconfig.extras.options.dap"),
		require("matchconfig.extras.options.luasnip_ft_extend"),
		require("matchconfig.options.run_buf"),
		require("matchconfig.options.run_buf_named"),
		require("matchconfig.options.run_session"),
		require("matchconfig.options.bufopt"),
		require("matchconfig.options.lsp"),
	}
})
require("matchconfig.util.log").set_loglevel("debug")

require("ltex").register_ltex_commands(function()
	vim.schedule(function()
		require("matchconfig.session").reload_same_opts(false)
	end)
end)

vim.api.nvim_create_user_command("C", mc.pick_current, {})
vim.api.nvim_create_user_command("CO", ":e " .. vim.uv.fs_realpath(require("matchconfig").get_configfile()), {})
vim.api.nvim_create_user_command("MC", function()
	print(vim.inspect(mc.get_config()))
end, {})

vim.api.nvim_create_user_command("LspRestart", function()
	local servers = require("matchconfig.options.lsp").lsp_client_pool.clients
	local servercommands = vim.tbl_map(function(server)
		return table.concat(server.cmd, " ")
	end, servers)
	vim.ui.select(
		servercommands,
		{ kind = "matchconfig_lsp_restart" },
		function(_, idx)
			servers[idx]:restart()
		end
	)
end, {})
