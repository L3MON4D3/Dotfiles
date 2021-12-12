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
vim.api.nvim_set_keymap('n', '<leader>co', '<cmd>lua require("Comment.api").gco()<Cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>cO', '<cmd>lua require("Comment.api").gcO()<Cr>', {noremap = true})
