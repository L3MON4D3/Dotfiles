local repl = require("repl")

function Insp(data)
	print(vim.inspect(data))
end

function Do_nvim_relative(filename)
	return dofile("/home/simon/.config/nvim/lua/"..filename)
end

-- before loading plugins!
require("configs")

dofile(vim.fn.stdpath("cache") .. "/packer/packer_compiled.lua")

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
	callback = function(args)
		vim.cmd([[
			"startinsert
			setlocal nonumber
			setlocal norelativenumber
			setlocal ft=term
		]])
		-- immediately enter bash, don't for other terminals.
		if args.file:match("bash$") then
			vim.cmd("startinsert")
		end
	end
})

-- set EDITOR to open files in this session. Prevents nested nvim-instance.
vim.env.EDITOR = "myNvimRemoteEdit.sh " .. vim.api.nvim_get_vvar("servername")

require("sighelp")
require("sighelp.snippet")
require("modes")
require("plugins")

-- vim.treesitter.query.add_directive("set_injection_filetype_snippet_file!", function(_, _, bufnr, _, metadata)
-- 	local name = vim.api.nvim_buf_get_name(bufnr)
-- 	-- get file-basename.
-- 	metadata.language = vim.fn.fnamemodify(name, ":t:r")
-- 	return true
-- end )
