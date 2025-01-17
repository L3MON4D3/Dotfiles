local repl = require("repl")

local function nnoremapsilent_buflocal(lhs, rhs)
	local callback = nil
	if type(rhs) == "function" then
		callback = rhs
		rhs = ""
	end
	vim.api.nvim_buf_set_keymap(0, "n", lhs, rhs, {noremap = true, silent = true, callback = callback})
end

local function bash_scratch()
	vim.cmd[[
		:silent e `mktemp /tmp/XXXX.sh`
		:set ft=bash
		:silent !chmod +x %
	]]
	local tmpfile_name = vim.api.nvim_buf_get_name(0)

	nnoremapsilent_buflocal(",i", function()
		repl.toggle("bash", "below 15 split", false)
	end)
	nnoremapsilent_buflocal(",,f", function()
		vim.cmd([[:write]])
		repl.send("bash", tmpfile_name)
	end)

	-- actually, don't remove the file, it might be nice to get back to it.
	-- + I don't think I'll use this excessively, so not too bad to clutter /tmp.
	---- remove file once buffer unloaded (happens on exit I hope).
	--vim.api.nvim_create_autocmd("BufUnload", function() os.execute("rm " .. tmpfile_name) end, {buffer=true})
end

vim.api.nvim_create_user_command("BashScratch", bash_scratch, {})
