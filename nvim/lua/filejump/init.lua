local util = require("util")
local get_filelocation = require("filejump.filelocation")
local function t(x) return vim.api.nvim_replace_termcodes(x, true, true, true)  end

-- buffers where the binding should be activated.
local function binding_valid_buf(bufnr)
	-- only for buffer
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	return bufname:match("^/") or vim.bo[bufnr].filetype == "repl" or vim.bo[bufnr].filetype == "term"
end

-- whether this window can be used for displaying some file.
local function file_display_window(win)
	local win_bufnr = vim.api.nvim_win_get_buf(win)
	-- only for buffer
	local bufname = vim.api.nvim_buf_get_name(win_bufnr)
	return bufname:match("^/") and vim.bo[win_bufnr].filetype ~= "repl" or vim.bo[win_bufnr].filetype ~= "term"
end

-- value for initial window? is static?
local last_valid_file_display_window = 1000
-- we want to track the window that displayed a valid buffer.
-- This value changes when switching windows and when a buffer becomes valid
-- through editing some other file (maybe?)
-- Although, if a window was valid once, I think in my usage, it should
-- continue being valid...
-- And, if I go with this, I'd need to make last_valid_file_display_window a
-- stack and pop off all invalid windows or something.
vim.api.nvim_create_autocmd({"VimEnter", "WinEnter"}, {
	pattern = "*",
	callback = function(args)
		local win = vim.api.nvim_get_current_win()
		if file_display_window(win) then
			last_valid_file_display_window = win
		end
	end
})

local function file_jump(filelocation)
	vim.api.nvim_tabpage_set_win(0, last_valid_file_display_window)
	vim.api.nvim_exec2("edit " .. filelocation.path, {})
	-- lets hope columns are always 1-indexed...
	-- maybe we need custom-behaviour
	vim.api.nvim_win_set_cursor(last_valid_file_display_window, {filelocation.row or 1, filelocation.col and (filelocation.col-1) or 0})
end

vim.keymap.set("n", "<Cr>", function()
	local buf = vim.api.nvim_get_current_buf()
	local win = vim.api.nvim_get_current_win()

	local cursor = util.get_cursor_0ind(win)
	local cursor_line = vim.api.nvim_buf_get_lines(buf, cursor[1], cursor[1]+1, true)[1]

	-- check paths relative to cwd+root via "", and local to file-directory via buf-directory.
	local paths = {util.bufname_to_dir(vim.api.nvim_buf_get_name(buf)), vim.loop.cwd()}
	-- +1: 0- to 1-based indexing.
	local filelocation_under_cursor = get_filelocation(paths, cursor_line, cursor[2]+1)
	if binding_valid_buf(buf) and filelocation_under_cursor ~= nil then
		vim.schedule(function()
			file_jump(filelocation_under_cursor)
		end)
		return t"<Ignore>"
	else
		return t"<Cr>"
	end
end, {noremap=true, expr=true})
