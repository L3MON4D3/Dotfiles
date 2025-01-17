local util = require("util")
local do_args_fn = require("matchconfig.util.actions").do_args_fn
local actions = require("matchconfig.util.actions")
local repl = require("repl")
local log = require("matchconfig.util.log").new("repl")

--- @class Repl: Matchconfig.Option
--- @field repl_specs table[]
local Repl = {}
local Repl_mt = { __index = Repl }

local dirdecode = vim.base64.decode
local direncode = vim.base64.encode

local primary = 1
local secondary = 2

local type_to_spec = {
	[primary] = {toggle_keys = ",i"},
	[secondary] = {toggle_keys = ",j"}
}

local function repl_mapping(args, repl_id, lhs, command)
	if type(command) == "function" then
		actions.nnoremapsilent_buf(lhs, function()
			repl.send(repl_id, command(args))
		end)
	else
		actions.nnoremapsilent_buf(lhs, function()
			repl.send(repl_id, command)
		end)
	end
end

local function fstring_fn(str)
	local eval_str = "return [[" .. str:gsub("%{", "]] .. "):gsub("%}", " .. [[") .. "]]"
	return loadstring(eval_str)
end
local function fstring_fn_eval(fn, args)
	setfenv(fn, {args = args, direncode = direncode, vim = vim})
	return fn()
end

local function get_repl_spec(config_raw)
	local spec = vim.deepcopy(config_raw.repl)

	if spec and spec.set_type and type(spec.set_type.id) == "string" then
		spec.set_type.id = fstring_fn(spec.set_type.id)
	end
	if spec and spec.run and type(spec.run.id) == "string" then
		spec.run.id = fstring_fn(spec.run.id)
	end

	if spec and spec.run and spec.run.mappings then
		local old_once = spec.run.once or util.nop
		local mappings = spec.run.mappings
		spec.run.once = function(args, repl_id)
			for lhs, rhs in pairs(mappings) do
				if type(rhs) == "string" then
					local ff = fstring_fn(rhs)
					rhs = fstring_fn_eval(ff, args)
				end
				repl_mapping(args, repl_id, lhs, rhs)
			end
			old_once(args, repl_id)
		end
		spec.run.mappings = nil
	end

	return spec
end

function Repl.new(config_raw)
	return setmetatable({
		repl_specs = {get_repl_spec(config_raw)}
	}, Repl_mt)
end

function Repl:copy()
	return vim.deepcopy(self)
end

function Repl:append_raw(t)
	table.insert(self.repl_specs, get_repl_spec(t))
end
function Repl:append(rb)
	vim.list_extend(self.repl_specs, rb.repl_specs)
end

-- use function to guarantee by-value copying!
local barrier = util.nop
function Repl:barrier()
	-- insert barriers to access correct barrier_args.
	table.insert(self.repl_specs, barrier)
end

---@class ReplApplicator: Matchconfig.OptionApplicator
---@field repl_specs table[]

local ReplApplicator = {}
local ReplApplicator_mt = {__index = ReplApplicator}
function ReplApplicator.new(repl_specs, barrier_args)
	return setmetatable({
		repl_specs = repl_specs,
		barrier_args = barrier_args,
		undolists = {}
	}, ReplApplicator_mt)
end

local function repl_id_components(id)
	local res = {}
	local so_far = ""
	for i, v in ipairs(vim.split(id, ".", {plain=true})) do
		res[i] = so_far .. v
		so_far = so_far .. v .. "."
	end
	return res
end

function ReplApplicator:apply_to_barrier(call_b_idx, args)
	args = vim.deepcopy(args)
	if call_b_idx ~= 1 then
		return
	end

	-- only specs, no barrier-entries.
	local specs = {}
	-- map i in specs to barrier-index to find barrier-args.
	local spec_i_to_barrier_args_i = {}
	local barrier_idx = 1
	for _, v in ipairs(self.repl_specs) do
		if v == barrier then
			barrier_idx = barrier_idx + 1
		else
			table.insert(specs, v)
			spec_i_to_barrier_args_i[#specs] = barrier_idx
		end
	end


	-- map repl-name to highest-priority known repl that includes it.
	-- {
	--	bash = bash.mitsuba,
	--	bash.mitsuba = bash.mitsuba,
	--	bash.mitsuba.qwer = bash.mitsuba.qwer,
	--	bash.mitsuba.asdf = bash.mitsuba.asdf,
	--	python = python.mitsuba,
	--	python.mitsuba = python.mitsuba
	-- }
	-- (in this example, bash.mitsuba is registered after bash.mitsuba.qwer).
	-- the most-specific known repl should be active, since it may receive commands.
	local effective_run_repl_id = {}
	local run_repl_ids_ordered = {}
	for i, spec in ipairs(specs) do
		args.match_args = self.barrier_args[spec_i_to_barrier_args_i[i]]

		if spec.set_type then
			spec.set_type.id = fstring_fn_eval(spec.set_type.id, args)
		end

		if spec.run then
			spec.run.id = fstring_fn_eval(spec.run.id, args)

			table.insert(run_repl_ids_ordered, spec.run.id)

			for _, comp in ipairs(repl_id_components(spec.run.id)) do
				effective_run_repl_id[comp] = spec.run.id
			end
		end
	end

	-- collect repls that may receive commands.
	-- the rule here is that commands for 
	local effective_repls = {}
	local effective_repl_type = {}
	for _, repl_id in pairs(effective_run_repl_id) do
		effective_repls[repl_id] = true
		effective_repl_type[repl_id] = primary
	end

	local seen = {}
	local effective_repls_ordered = util.list_filter(run_repl_ids_ordered, function(id)
		local valid = effective_repls[id] and not seen[id]
		seen[id] = true
		return valid
	end)

	for _, spec in ipairs(specs) do
		if spec.set_type then
			for _, repl_id in ipairs(effective_repls_ordered) do
				if vim.startswith(repl_id, spec.set_type.id) then
					effective_repl_type[repl_id] = spec.set_type.type
				end
			end
		end
	end

	log.info("Buffer %s has effective repls %s", args.file, vim.inspect(effective_repls_ordered))

	for _, repl_id in ipairs(effective_repls_ordered) do
		table.insert(
			self.undolists,
			do_args_fn(function()
				actions.nnoremapsilent_buf(type_to_spec[effective_repl_type[repl_id]].toggle_keys, function()
					repl.toggle(repl_id, "below 15 split", false)
				end)
			end, args))
	end

	for i, spec in ipairs(specs) do
		args.match_args = self.barrier_args[spec_i_to_barrier_args_i[i]]

		if spec.run then
			if spec.run.once then
				table.insert(
					self.undolists,
					do_args_fn(
						spec.run.once,
						args,
						effective_run_repl_id[spec.run.id]))
			end
			if spec.run.type then
				for _, effective_repl_id in ipairs(effective_repls_ordered) do
					if vim.startswith(effective_repl_id, spec.run.id) then
						table.insert(
							self.undolists,
							do_args_fn(
								spec.run.type,
								args,
								effective_run_repl_id[spec.run.id],
								type_to_spec[effective_repl_type[effective_repl_id]]))
					end
				end
			end
		end
	end
end

function ReplApplicator:undo(_)
	for _, undolist in ipairs(self.undolists) do
		undolist:run()
	end
end

function Repl:make_applicator(barrier_args)
	return ReplApplicator.new(vim.deepcopy(self.repl_specs), barrier_args)
end

function Repl:reset() end

return {
	new = Repl.new,
	reset = util.nop,
	dirdecode = dirdecode,
	direncode = direncode,
	primary = primary,
	secondary = secondary
}
