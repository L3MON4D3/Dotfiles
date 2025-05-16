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
vim.api.nvim_create_user_command("C", mc.pick_current, {})
vim.api.nvim_create_user_command("CO", ":e " .. vim.uv.fs_realpath(require("matchconfig").get_configfile()), {})
vim.api.nvim_create_user_command("MC", function()
	print(vim.inspect(mc.get_config()))
end, {})
