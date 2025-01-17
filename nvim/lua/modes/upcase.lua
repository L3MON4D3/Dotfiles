local libmodal = require("libmodal")

local alphabet = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}

local keymaps = {}

-- replace lowercase-letters with uppercase-variants.
for _, char in ipairs(alphabet) do
	keymaps[char] = { rhs = char:upper()}
end
-- replace space with underscore.
keymaps["<space>"] = {rhs = "_"}

local layer

keymaps["<esc>"] = {rhs = function()
	layer:exit()
end}
layer = libmodal.layer.new({ i = keymaps })

vim.keymap.set("i", "<C-u>", function()
	layer:enter()
end)
