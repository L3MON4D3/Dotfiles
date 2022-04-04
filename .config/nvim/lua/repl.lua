local api = vim.api

local M = {}

local commands = {
	julia = {"julia", "-q", "-J/home/simon/.julia/sysimages/GLMakieImage.so"}
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
	nop(terminals[term_id])
end

function M.send(term_id, cmd)
	api.nvim_chan_send(terminals[term_id].channel, cmd .. "\n")
end

function M.show(term_id)
	api.nvim_set_current_buf(terminals[term_id].buf)
end

function M.toggle(term_id, split_command, focus)
	local tabpage = vim.fn.tabpagenr()
	local win = windows[term_id][tabpage]
	if win and api.nvim_win_is_valid(win) then
		api.nvim_win_close(win, true)
		windows[term_id][tabpage] = nil
	else
		local current_win = api.nvim_tabpage_get_win(tabpage)
		vim.cmd(split_command)
		local split_win = api.nvim_tabpage_get_win(tabpage)

		if not focus then
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

return M
