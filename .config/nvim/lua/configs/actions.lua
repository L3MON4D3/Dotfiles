--- @class Undolist
local Undolist = {}
local Undolist_mt = { __index = Undolist }

function Undolist.new()
	return setmetatable({}, Undolist_mt)
end
function Undolist:run()
	for i = #self, 1, -1 do
		self[i]()
	end
end
function Undolist:append(fn)
	table.insert(self, fn)
end

local undo_callbacks_name = "__action_undo"
local bufnr_name = "__action_bufnr"
-- args like the argument passed to autocmd-callback.
local function do_args_fn(fn, args)
	local undolist = Undolist.new()
	setfenv(fn, setmetatable({
		[undo_callbacks_name] = undolist,
		[bufnr_name] = args.buf,
	}, {__index = _G}))
	fn(args)
	return undolist
end

local function callstack_find_undo_buf()
	local current = 2
	while current < 100 do
		local fenv = getfenv(current)
		local undo = fenv[undo_callbacks_name]
		local buf = fenv[bufnr_name]
		if undo and buf then
			return undo, buf
		end
		current = current + 1
	end
	error("called callstack_find_undo_buf while not in ActionContext:do_args_fn")
end
return {
	nnoremapsilent_buf = function(lhs, rhs)
		local undo, buf = callstack_find_undo_buf()

		local callback = nil
		if type(rhs) == "function" then
			callback = rhs
			rhs = ""
		end
		vim.api.nvim_buf_set_keymap(buf, "n", lhs, rhs, {noremap = true, silent = true, callback = callback})

		undo:append(function()
			-- pcall in the case that the mapping is already removed somehow.
			-- (maybe two run_buf map the same lhs, then there would be an
			-- error on undoing both of them)
			pcall(vim.api.nvim_buf_del_keymap, buf, "n", lhs)
		end)
	end,
	-- the same, up to the obvious change.
	vnoremapsilent_buf = function(lhs, rhs)
		local undo, buf = callstack_find_undo_buf()

		local callback = nil
		if type(rhs) == "function" then
			callback = rhs
			rhs = ""
		end
		vim.api.nvim_buf_set_keymap(buf, "v", lhs, rhs, {noremap = true, silent = true, callback = callback})

		undo:append(function()
			pcall(vim.api.nvim_buf_del_keymap, buf, "v", lhs)
		end)
	end,
	cabbrev_buf = function(lhs, rhs)
		local undo, buf = callstack_find_undo_buf()

		vim.api.nvim_buf_set_keymap(buf, "ca", lhs, rhs, {})

		undo:append(function()
			pcall(vim.api.nvim_buf_del_keymap, buf, "ca", lhs)
		end)
	end,
	do_args_fn = do_args_fn
}
