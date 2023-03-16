local api = vim.api

local M = {}

local commands = {
	julia = {"julia", "-q", "--threads=1", "-J" ,"/home/simon/.julia/sysimages/mine2.so"},
	python = {"ipython"},
	bash = {"bash"}
}

local terminals = setmetatable({}, {
	__index = function(t, k)
		local buf = api.nvim_create_buf(false, false)

		local prev_buf = api.nvim_get_current_buf()

		api.nvim_set_current_buf(buf)
		local channel = vim.fn.termopen(commands[k])
		api.nvim_set_current_buf(prev_buf)

		local res = {channel = channel, buf = buf}
		rawset(t, k, res)
		return res
	end
})

local windows = setmetatable({}, {
	__index = function(t, k)
		local res = {}
		rawset(t, k, res)
		return res
	end
})

local function nop(_) end
function M.ensure_enabled(term_id)
	if not api.nvim_buf_is_valid(terminals[term_id].buf) then
		-- restart.
		terminals[term_id] = nil
		nop(terminals[term_id])
	end
end

function M.send(term_id, cmd)
	M.ensure_enabled(term_id)
	api.nvim_chan_send(terminals[term_id].channel, cmd .. "\n")
end

function M.show(term_id)
	M.ensure_enabled(term_id)
	api.nvim_set_current_buf(terminals[term_id].buf)
end

function M.toggle(term_id, split_command, focus)
	M.ensure_enabled(term_id)
	local tabpage = vim.fn.tabpagenr()
	local win = windows[term_id][tabpage]
	if win and api.nvim_win_is_valid(win) then
		api.nvim_win_close(win, true)
		windows[term_id][tabpage] = nil
	else
		-- gets active window.
		local current_win = api.nvim_tabpage_get_win(tabpage)
		vim.cmd(split_command)
		local split_win = api.nvim_tabpage_get_win(tabpage)
		api.nvim_win_set_option(split_win, "winfixheight", true)
		-- probably also good?
		api.nvim_win_set_option(split_win, "winfixwidth", true)

		if not focus  then
			_G._insert_term_skip = true
			api.nvim_set_current_win(current_win)
			api.nvim_win_set_buf(split_win, terminals[term_id].buf)
			_G._insert_term_skip = false
		else
			api.nvim_set_current_buf(terminals[term_id].buf)
		end
		windows[term_id][tabpage] = split_win
	end
end

function M.restart(term_id)
	terminals[term_id] = nil
end

return M
