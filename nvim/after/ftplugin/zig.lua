local repl = require("repl")

vim.keymap.set("n", ",i", function()
	repl.toggle("bash", "below 15 split", false)
end)

