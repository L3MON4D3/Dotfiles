local api = vim.api

local M = {}

local commands = {
	julia = {"julia", "-q", "--threads=1", "-J", "/home/simon/.julia/sysimages/img.so"},
	python = {"ipython"},
	bash = {"bash"},
	juwels = {"ssh", "juwels"},
	jureca = {"ssh", "jureca"},
}

local term_opts = {}

local function create_term(command, opts)
	opts = opts or {}
	local job_opts = opts.job_opts or {}

	local res = {}

	local job_id

	local buf = api.nvim_create_buf(true, false)
	api.nvim_buf_set_name(buf, ("term://%s/%s"):format(buf, command[1]))
	res.buf = buf

	vim.api.nvim_buf_call(buf, function()
		job_id = vim.fn.termopen(command, vim.tbl_extend("force", {
			on_stdout = function(_, _)
				-- set terminal as active as soon as we got some output.
				-- (useful for delaying input until there has been a first sign
				-- of activity from the job.)
				vim.defer_fn(function()
					res.active = true
				end, 0)
			end,
			on_exit = function()
				vim.api.nvim_buf_delete(buf, {force = true})
			end,
			pty = true,
		}, job_opts))
	end)
	res.channel = job_id

	return res
end

-- map stuff like julia, python, bash (term_id) to table with keys
-- * channel (the channel to the external process)
-- * buf (the buffer)
local terminals = setmetatable({}, {
	__index = function(t, k)
		local term_id = k
		local term_type = term_id:match("^[^%.]+")
		local res = create_term(commands[term_type], term_opts[term_id])
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

	local send_fn
	send_fn = function()
		if terminals[term_id].active then
			api.nvim_chan_send(terminals[term_id].channel, cmd .. "\n")
		else
			-- schedule for another try in 50ms.
			vim.defer_fn(send_fn, 50)
		end
	end
	send_fn()
end

function M.show(term_id)
	M.ensure_enabled(term_id)
	api.nvim_set_current_buf(terminals[term_id].buf)
end

local function open_new(tabpage, split_command, focus, buf)
	-- gets active window.
	local current_win = api.nvim_tabpage_get_win(tabpage)
	vim.cmd(split_command)
	local split_win = api.nvim_tabpage_get_win(tabpage)

	if not focus then
		_G._insert_term_skip = true
		api.nvim_set_current_win(current_win)
		api.nvim_win_set_buf(split_win, buf)
		_G._insert_term_skip = false
	else
		api.nvim_set_current_buf(buf)
	end

	-- Don't take up more space than allocated from split command.
	vim.wo[split_win].winfixheight = true
	vim.wo[split_win].winfixwidth = true

	-- hide left column, disabling numbers is enough.
	vim.wo[split_win].number = false
	vim.wo[split_win].relativenumber = false

	-- all have the same filetype.
	vim.bo[buf].ft = "term"

	return split_win
end

function M.toggle(term_id, split_command, focus)
	M.ensure_enabled(term_id)
	local tabpage = vim.api.nvim_win_get_tabpage(0)
	local win = windows[term_id][tabpage]
	if win and api.nvim_win_is_valid(win) then
		api.nvim_win_close(win, true)
		windows[term_id][tabpage] = nil
	else
		local win_id = open_new(tabpage, split_command, focus, terminals[term_id].buf)
		windows[term_id][tabpage] = win_id
	end
end

function M.open_unique(command, split_command, focus)
	local term_data = create_term(command)
	local tabpage = vim.api.nvim_win_get_tabpage(0)
	open_new(tabpage, split_command, focus, term_data.buf)
end

function M.restart(term_id)
	terminals[term_id] = nil
end

function M.set_opts(term_id, opts)
	term_opts[term_id] = opts
end

return M
