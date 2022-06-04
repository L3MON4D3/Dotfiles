local repl = require("repl")

function Insp(data)
	print(vim.inspect(data))
end

function Do_nvim_relative(filename)
	return dofile("/home/simon/.config/nvim/lua/"..filename)
end

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "term://*",
	callback = function()
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

vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		vim.cmd([[
			startinsert
			setlocal nonumber
			setlocal norelativenumber
			setlocal ft=term
		]])
	end
})

-- set EDITOR to open files in this session. Prevents nested nvim-instance.
vim.env.EDITOR = "myNvimRemoteEdit.sh " .. vim.api.nvim_get_vvar("servername")

require("sighelp")
