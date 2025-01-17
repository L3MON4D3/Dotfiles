hop = require("hop")
hop.setup()

vim.cmd[[
nnoremap <silent> \ <cmd>lua hop.hint_words()<Cr>
nnoremap <silent> \| <cmd>lua hop.hint_char1()<Cr>
]]
