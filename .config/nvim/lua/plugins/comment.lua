require("Comment").setup{
	toggler = {
		block = '<leader>bb',
		line = '<leader>cc'
	},
	opleader = {
		line = '<leader>c',
		block = '<leader>b'
	},
}
vim.api.nvim_set_keymap('n', '<leader>co', '<cmd>lua require("Comment.api").insert_linewise_below()<Cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>cO', '<cmd>lua require("Comment.api").insert_linewise_above()<Cr>', {noremap = true})
