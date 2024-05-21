local do_args_fn = require("configs.actions").do_args_fn

--- @class Option
--- @field append_raw fun(Option, table)
--- @field append fun(Option, Option)
--- @field apply fun(Option, Option)
--- @field undo fun(Option, integer)

--- @class Dap: Option
--- @field type_configs table<string, table>
local Dap = {}
local Dap_mt = { __index = Dap }

function Dap.new(config)
	local type_configs = {}
	if config.dap then
		for _, dap_conf in ipairs(config.dap) do
			type_configs[dap_conf.my_type] = dap_conf
		end
	end

	return setmetatable({
		type_configs = type_configs,
	}, Dap_mt)
end

function Dap:apply(args)
	local dap = require("dap")
	local config_list = {}
	for _, v in pairs(self.type_configs) do
		table.insert(config_list, v)
	end

	vim.keymap.set("n", "<F5>", function()
		if dap.session() then
			-- session active, just do regular continue.
			dap.continue()
			return
		end

		-- otherwise, open picker to select from possible configs.
		require("dap.ui").pick_if_many(
			config_list,
			"Configuration: ",
			function(i) return i.name end,
			function(configuration)
				if configuration then
					vim.notify('Running configuration ' .. configuration.name, vim.log.levels.INFO, {title = "DAP"})
					dap.run(configuration)
				else
					vim.notify('No configuration selected', vim.log.levels.INFO, {title = "DAP"})
				end
			end
		)
	end, { buffer = args.buf })
end

function Dap:append_raw(t)
	if t.dap then
		for _, dap_conf in ipairs(t.dap) do
			self.type_configs[dap_conf.my_type] = dap_conf
		end
	end
end
function Dap:append(dap)
	for type, dap_conf in pairs(dap.type_configs) do
		self.type_configs[type] = dap_conf
	end
end

function Dap:undo(bufnr, _)
	pcall(vim.keymap.del, "n", "<F5>", { buffer = bufnr })
end


--- @class RunBuf: Option
--- @field buf_fns fun(table)[]
--- @field undolists Undolist[]
local RunBuf = {}
local RunBuf_mt = { __index = RunBuf }
function RunBuf.new(configs)
	return setmetatable({
		buf_fns = {configs.run_buf},
		undolists = {}
	}, RunBuf_mt)
end

function RunBuf:append_raw(t)
	table.insert(self.buf_fns, t.run_buf)
end
function RunBuf:append(rb)
	local l = #self.buf_fns
	for i, fn in ipairs(rb.buf_fns) do
		self.buf_fns[l+i] = fn
	end
end

function RunBuf:apply(args)
	for _, fn in ipairs(self.buf_fns) do
		table.insert(self.undolists, do_args_fn(fn, args))
	end
end
function RunBuf:undo()
	for _, undolist in ipairs(self.undolists) do
		undolist:run()
	end
end
function RunBuf:reset() end

--- @class RunSession: Option
--- @field session_fns fun(table)[]
local RunSession = {
	fn_undolist = {}
}
local RunSession_mt = { __index = RunSession }
function RunSession.new(config)
	return setmetatable({
		session_fns = {config.run_session},
	}, RunSession_mt)
end

function RunSession:append_raw(t)
	table.insert(self.session_fns, t.run_session)
end
function RunSession:append(rb)
	local l = #self.session_fns
	for i, fn in ipairs(rb.session_fns) do
		self.session_fns[l+i] = fn
	end
end

function RunSession:apply(args)
	for _, fn in ipairs(self.session_fns) do
		-- make sure we only execute session-fn if it wasn't run already.
		if not RunSession.fn_undolist[fn] then
			RunSession.fn_undolist[fn] = do_args_fn(fn, args)
		end
	end
end
function RunSession:undo()
	for _, fn in ipairs(self.session_fns) do
		local fn_undolist = RunSession.fn_undolist[fn]
		if fn_undolist then
			fn_undolist:run()
			RunSession.fn_undolist[fn] = nil
		end
	end
end
function RunSession.reset() RunSession.executed_fns = {} end


--- @class LuasnipFT: Option
--- @field ft_extensions table<string, string[]>
local LuasnipFT = {}
local LuasnipFT_mt = { __index = LuasnipFT }
function LuasnipFT.new(config)
	return setmetatable({
		ft_extensions = config.luasnip_ft_extend or {}
	}, LuasnipFT_mt)
end

local function extend_ft_extensions(extendee, extend_vals)
	for ft, extensions in pairs(extend_vals) do
		if not extendee[ft] then
			extendee[ft] = extensions
		else
			vim.list_extend(extendee[ft], extensions)
		end
	end
end
function LuasnipFT:append_raw(t)
	extend_ft_extensions(self.ft_extensions, t.luasnip_ft_extend or {})
end
function LuasnipFT:append(l)
	extend_ft_extensions(self.ft_extensions, l.ft_extensions)
end

function LuasnipFT:apply(args)
	vim.b[args.buf].luasnip_ft_extend = self.ft_extensions
end
function LuasnipFT:undo(bufnr)
	vim.b[bufnr].luasnip_ft_extend = {}
end
function LuasnipFT.reset() end


return {
	run_buf = RunBuf,
	run_session = RunSession,
	dap = Dap,
	luasnip_ft_extend = LuasnipFT
}
