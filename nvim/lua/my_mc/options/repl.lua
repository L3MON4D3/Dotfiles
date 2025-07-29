local util = require("util")
local do_args_fn = require("matchconfig.util.actions").do_args_fn
local actions = require("matchconfig.util.actions")
local repl = require("repl")
local log = require("matchconfig.util.log").new("repl")
local tbl_util = require("matchconfig.util.table")
local eval_util = require("matchconfig.options.util.eval")
-- local autotable = require("matchconfig.util.autotable").warn_depth_autotable
local merge = require("matchconfig.options.util.merge")

--- @class Repl: Matchconfig.Option
--- @field repl_specs table[]
local Repl = {}
local Repl_mt = { __index = Repl }

local dirdecode = vim.base64.decode
local direncode = vim.base64.encode

---@enum ReplTarget
local repl_target = {
	file = 1,
	project = 2,
	all = 3
}

local target_toggle_keys = {
	[repl_target.file] = ",i",
	[repl_target.project] = ",j"
}

local function get_repl_spec(config_raw)
	return vim.deepcopy(config_raw.repl)
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

local base_cmd = {
	bash = "bash",
	python = "ipython",
	julia = "julia"
}

-- leaves are all datatypes except tables with only non-numerical values.
local function is_inner_node(t)
	return type(t) == "table" and (not t[1]) and getmetatable(t) == nil
end

function ReplApplicator:apply_to_barrier(call_b_idx, args)
	if call_b_idx ~= 1 then
		return
	end

	local specs_no_eval = {}
	local barrier_i = 1
	for _, spec in ipairs(self.repl_specs) do
		if spec == barrier then
			barrier_i = barrier_i + 1
		else
			local args_final = vim.deepcopy(args)
			args_final.match_args = self.barrier_args[barrier_i]
			tbl_util.tbl_do(spec, function(imm_parent, keys_abs, v)
				if eval_util.is_eval(v) then
					imm_parent[keys_abs[#keys_abs]] = v:apply(args_final)
					return false
				end
				return true
			end)
			local original = spec.run or util.nop
			local mappings = spec.mappings or {}
			-- these functions have to be compatible with the framework from `actions`.
			spec.run = function(_dummy_args, repl_id, toggle_keys)
				original(args_final, repl_id, toggle_keys)
				for keys, mapping in pairs(mappings or {}) do
					if type(mapping) == "function" then
						mapping = mapping(args_final)
					end
					actions.nnoremapsilent_buf(keys, function()
						repl.send(repl_id, mapping)
					end)
				end
			end
			spec.mappings = nil
			table.insert(specs_no_eval, spec)
		end
	end

	local final = {
		[repl_target.file] = {},
		[repl_target.project] = {}
	}
	local last_type = {
		[repl_target.file] = nil,
		[repl_target.project] = nil
	}

	for _, spec in ipairs(specs_no_eval) do
		assert(spec.type)
		assert(spec.target)

		for _, target in ipairs({repl_target.file, repl_target.project}) do
			if spec.target ~= target and spec.target ~= repl_target.all then
				goto continue
			end

			if not final[target][spec.type] then
				final[target][spec.type] = {
					cmd = base_cmd[spec.type],
					opts = {},
					mappings = {},
					run = {},
				}
			end

			local old = final[target][spec.type]
			if spec.cmd then
				if merge.is_mergeop(spec.cmd) then
					old.cmd = spec.cmd:apply(old.cmd)
				else
					old.cmd = spec.cmd
				end
			end
			if spec.mappings then
				if merge.is_mergeop(spec.mappings) then
					old.mappings = spec.cmd:apply(old.mappings)
				else
					vim.list_extend(old.mappings, spec.mappings)
				end
			end
			if spec.run then
				table.insert(old.run, spec.run)
			end
			tbl_util.tbl_do(spec.opts or {}, function(_, key_abs, v)
				if is_inner_node(v) then
					-- not a leaf, recurse.
					return true
				end
				-- we are dealing with a terminal value.
				if merge.is_mergeop(v) then
					-- replace value in specs_merged with apply-value.
					v = v:apply(tbl_util.get(old.opts, key_abs))
				end

				tbl_util.set(old.opts, key_abs, v)
				-- don't recurse.
				return false
			end)

			last_type[target] = spec.type

			::continue::
		end
	end

	for _, target in ipairs({repl_target.file, repl_target.project}) do
		if not last_type[target] then
			goto continue
		end

		local spec = final[target][last_type[target]]
		local repl_id = repl.get_id({
			cmd = spec.cmd,
			job_opts = spec.opts
		})

		table.insert(
			self.undolists,
			do_args_fn(function()
				actions.nnoremapsilent_buf(target_toggle_keys[target], function()
					repl.toggle(repl_id, "below 15 split", false)
				end)
			end, args))

		for _, fn in ipairs(spec.run) do
			table.insert(
				self.undolists,
				do_args_fn(
					fn,
					args,
					repl_id, target_toggle_keys[target]))
		end

		::continue::
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
	repl_target = repl_target
}
