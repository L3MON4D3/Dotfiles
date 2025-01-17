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


local config = require("Comment.config"):get()

vim.keymap.set("n", "<leader>o", function()
	require("Comment.api").insert.linewise.below(config)
end, {noremap = true})
vim.keymap.set("n", "<leader>O", function()
	require("Comment.api").insert.linewise.above(config)
end, {noremap = true})
vim.keymap.set("n", "<leader>A", function()
	require("Comment.api").insert.linewise.eol(config)
end, {noremap = true})
