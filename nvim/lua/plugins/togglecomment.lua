local tc = require("togglecomment")
vim.keymap.set({"n","v"}, "<leader>d", tc.comment, {noremap = true, silent = true})
