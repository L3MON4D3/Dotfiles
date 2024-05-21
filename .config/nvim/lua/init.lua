I = vim.print
Insp = vim.print

function Do_nvim_relative(filename)
	return dofile("/home/simon/.config/nvim/lua/"..filename)
end

local repl = require("repl")

-- before loading plugins!
require("configs").setup("/home/simon/.config/nvim/configs.lua")

require("plugins")

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "term://*",
	callback = function(args)
		if _G._insert_term_skip then
			return
		end

		if vim.b.mode == nil then
			vim.b.mode = "i"
			vim.cmd("startinsert")
		else
			if vim.b.mode == "i" then
				vim.cmd("startinsert")
			end
		end
	end
})

vim.keymap.set("n", "<F11>", function()
	repl.open_unique({"bash"}, "split", true)
end, {noremap = true, silent = true})
-- F23 = S-F11.
vim.keymap.set("n", "<F23>", function()
	repl.open_unique({"bash"}, "vsplit", true)
end, {noremap = true, silent = true})

vim.keymap.set("n", "<leader>d", require("toggle_comment"), {noremap = true, silent = true})

-- set EDITOR to open files in this session. Prevents nested nvim-instance.
vim.env.EDITOR = "myNvimRemoteEdit.sh " .. vim.api.nvim_get_vvar("servername")

vim.g.editorconfig = true

require("sighelp")
require("sighelp.snippet")
require("modes")
require("bash-scratch")
require("write")

-- vim.treesitter.query.add_directive("set_injection_filetype_snippet_file!", function(_, _, bufnr, _, metadata)
-- 	local name = vim.api.nvim_buf_get_name(bufnr)
-- 	-- get file-basename.
-- 	metadata.language = vim.fn.fnamemodify(name, ":t:r")
-- 	return true
-- end )

-- mappings and commands

vim.api.nvim_create_user_command("O", function()
	vim.api.nvim_input(":tabnew<Cr>:e ~/Documents/base<Cr>:normal gh<Cr>")
end, {})

-- predicate used by lua/togglecomment.scm
vim.treesitter.query.add_predicate("root-child", function(match, _, _, predicate)
	local node = match[predicate[2]]
	return node:parent():parent() == nil
end)
