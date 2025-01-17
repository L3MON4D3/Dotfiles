local builtin_pickers = require("telescope.builtin")

vim.api.nvim_create_user_command("SP", builtin_pickers.lsp_document_symbols, {})
vim.api.nvim_set_keymap("n", "gb", "", {
	callback = function()
		builtin_pickers.buffers()
	end,
	silent = true
})
