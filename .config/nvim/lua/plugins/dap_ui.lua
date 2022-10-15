require("dapui").setup({
	layouts = {
		{
			elements = {
				"stacks",
				"scopes",
				"watches"
			},
			size = 40,
			position = "tray"
		}
	},
})

vim.cmd([[command! DapUI :lua require("dapui").toggle()]])
