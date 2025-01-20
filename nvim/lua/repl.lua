local api = vim.api

local M = {}

local function create_term(command, job_opts)
	job_opts = job_opts or {}

	local res = {}

	local job_id

	local buf = api.nvim_create_buf(true, false)
	api.nvim_buf_set_name(buf, ("term://%s/%s"):format(buf, command[1]))
	res.buf = buf

	vim.api.nvim_buf_call(buf, function()
		job_id = vim.fn.jobstart(command, vim.tbl_extend("force", {
			on_exit = function(...)
				-- buffer is deleted automatically sometimes.
				pcall(vim.api.nvim_buf_delete, buf, {force = true})
				if job_opts.on_exit then
					job_opts.on_exit(...)
				end
			end,
			pty = true,
			term = true
		}, job_opts))
	end)

	res.channel = job_id

	return res
end

-- cmd and job_opts have to be set.
local term_specs = {
	bash = {
		cmd = {"bash"},
		job_opts = {}
	},
	julia = {
		cmd = {"julia", "-q", "--threads", "12"},
		job_opts = {}
	},
	python = {
		cmd = {"ipython"},
		job_opts = {}
	}
}

local term_spec_generators = { }

local function get_term_spec(term_id)
	local term_spec = term_specs[term_id]
	if term_spec then
		return term_spec
	end
	for _, gen in pairs(term_spec_generators) do
		term_spec = gen(term_id)
		if term_spec then
			return term_spec
		end
	end
end

local send_enqueue

-- map stuff like julia, python, bash (term_id) to table with keys
-- * channel (the channel to the external process)
-- * buf (the buffer)
-- * active (false, set to true once there is some stdout)
-- * on_next_stdout: list of functions called in-order on the next stdout, and reset after it.
local terminals = {}
setmetatable(terminals, {
	__index = function(t, k)
		local term_id = k
		if not term_id then
			error("term_id is nil")
		end
		local term_spec = get_term_spec(term_id)
		if not term_spec then
			error("No term spec available for term_id " .. term_id)
		end
		local original_job_opts = term_spec.job_opts
		local effective_job_opts = vim.deepcopy(original_job_opts)

		local res = {}
		effective_job_opts.on_stdout = function(...)
			res.active = true
			if #res.on_next_stdout > 0 then
				for _, cb in ipairs(res.on_next_stdout) do
					cb(...)
				end
				-- clear list.
				res.on_next_stdout = {}
			end

			if original_job_opts.on_stdout then
				original_job_opts.on_stdout(...)
			end
		end

		local ct_res = create_term(term_spec.cmd, effective_job_opts)
		res.buf = ct_res.buf
		res.channel = ct_res.channel
		res.on_next_stdout = {}
		res.active = false

		if effective_job_opts.initial_keys then
			send_enqueue(res, effective_job_opts.initial_keys)
		end

		rawset(t, k, res)
		return res
	end
})

M.terminals = terminals

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

function send_enqueue(term_spec, cmd)
	table.insert(term_spec.on_next_stdout, function()
		vim.defer_fn(function()
			api.nvim_chan_send(term_spec.channel, cmd .. "\n")
		end, 10)
	end)
end

function M.send(term_id, cmd)
	M.ensure_enabled(term_id)

	if not terminals[term_id].active then
		send_enqueue(terminals[term_id], cmd .. "\n")
	else
		api.nvim_chan_send(terminals[term_id].channel, cmd .. "\n")
	end
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
	local term_data = create_term(command, {})
	local tabpage = vim.api.nvim_win_get_tabpage(0)
	open_new(tabpage, split_command, focus, term_data.buf)
end

function M.restart(term_id)
	terminals[term_id] = nil
end
function M.stop(term_id)
	terminals[term_id] = nil
end

function M.set_term(term_id, cmd, job_opts)
	-- if term_specs[term_id] then
		-- error("Trying to add term with duplicated term_id " .. term_id .. ", aborting!")
	-- end
	term_specs[term_id] = {
		cmd = cmd,
		job_opts = job_opts
	}
end

function M.set_term_generator(generator_id, fn)
	term_spec_generators[generator_id] = fn
end

return M
