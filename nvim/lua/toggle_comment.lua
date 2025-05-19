--- Idea: reject blockcomment if the found node does not extend until the end of the line.
--- If it doesn't, there's probably another higher-level node that does, and
--- commenting only part of it is likely bad.

local util = require("util")

---
--- I want to extend this with support for block-comments.
--- They are difficult because nesting is not supported for them, usually, so
--- it seems like the only way to reliably toggle them for an arbitrary region,
--- even if it already contains a block-comment, is to remove the
--- block-comment, and restore it upon uncommenting the region.
--- I think it's possible to do this satisfactorily by replacing the nested
--- block-comment characters with some other symbol(s).
---
--- One difficulty here is correctly handling and preserving nested block-comments.
--- For example, if we always use the same symbol for block-end, uncommenting
--- would restore the hidden block-end of a nested comment, and thus result in
--- invalid source code.
---
--- So, we have to make sure that, when commenting some region, we have to use
--- a character-sequence that does not already occur in the region.
--- One safe procedure is establishing a fixed (but probably infinite) ordered set of
--- strings-pairs (one for block-start, one for block-end) that are unlikely to
--- appear in the program-text.
--- On commenting, we scan the region for all symbols of this set and find the largest.
--- We can use any symbol that is larger than this one to replace existing
--- block-comments.
---
--- On uncommenting, we could scan the text for all such symbols, pick the
--- largest, and only replace these with the actual block-start/block-end
--- symbols.
---
--- (Improvement: do one scan, store positions of symbols, find largest we
--- encountered and replace from the back. Reduces number of scans to 1 from 2)
---
--- It remains to pick a fitting alphabet.
--- I think it makes sense to simply encode integers into characters by
--- converting their base and translating these symbols to any alphabet.
--- This allows using a minimal number of characters that are deemed
--- non-intrusive.
---
--- My pick would be any selection of zero-width characters which don't have a
--- good meaning for soruce code (joiners and the like), but simply
--- base64-chars would also suffice and allow a compact representation with
--- simple ascii (which may be good depending on the programming language,
--- maybe the compiler can't handle unicode, even in comments).
---

local PrefixcommentDef = {
	from = 1,
	connect = 2,
	to = 3,
	singleline = 4,
	connect_maybe = 5
}
PrefixcommentDef.__index = PrefixcommentDef

-- https://unicode-explorer.com/articles/space-characters
local unicode_space_list = {
	" ", -- U+00A0
	" ", -- U+2000
	" ", -- U+2001
	" ", -- U+2002
	" ", -- U+2003
	" ", -- U+2004
	" ", -- U+2005
	" ", -- U+2006
	" ", -- U+2007
	" ", -- U+2008
	" ", -- U+2009
	" ", -- U+200a
	" ", -- U+202f
	" ", -- U+205f
}

local alt_space_chars = {
	--[[ en_quad = --]] " ",
	--[[ em_quad = --]] " ",
	--[[ en_space = --]] " ",
	--[[ em_space = --]] " "
	-- --[[ en_quad = --]] "f",
	-- --[[ em_quad = --]] "t",
	-- --[[ en_space = --]] "c",
	-- --[[ em_space = --]] "s"
}

for i = 1, 4 do
	for j = i+1, 4 do
		if alt_space_chars[i] == alt_space_chars[j] then
			error("space-characters are represented by the same codepoint")
		end

		if #alt_space_chars[i] ~= #alt_space_chars[j] then
			error("space-characters have inequal byte-length.")
		end
	end
end

function PrefixcommentDef.new(commentchars)
	return setmetatable({
		prefixes = {
			[commentchars .. alt_space_chars[1]] = PrefixcommentDef.from,
			[commentchars .. alt_space_chars[2]] = PrefixcommentDef.to,
			[commentchars .. alt_space_chars[3]] = PrefixcommentDef.connect,
			[commentchars .. alt_space_chars[4]] = PrefixcommentDef.singleline,
		},

		sfrom = commentchars .. alt_space_chars[1],
		sto = commentchars .. alt_space_chars[2],
		sconnect = commentchars .. alt_space_chars[3],
		ssingleline = commentchars .. alt_space_chars[4],

		prefix_len = #commentchars + #alt_space_chars[1]
	}, PrefixcommentDef)
end

function PrefixcommentDef:linetype(line)
	if line:match("^%s*$") then
		return PrefixcommentDef.connect_maybe
	end
	local _, whitespace_to = line:find("^%s*")
	return self.prefixes[line:sub(whitespace_to+1, whitespace_to+self.prefix_len)]
end
-- returns the column where a comment should be inserted/where the comment is
-- at. These should always be the same.
-- nil if there should be no comment on this line.
function PrefixcommentDef:comment_at_col(line)
	if line:match("^%s*$") then
		return nil
	end
	local _, whitespace_to = line:find("^%s*")
	return whitespace_to
end

local lang_blockcomment = {
	-- lua = { [===[--[=[ ]===], [===[ ]=]]===] },

	-- xml can handle nested comments (?).
	xml = { "<?comment ", " ?>"},

	-- cpp = { "/* ", " */"}
}
local lang_prefixcomment = {
	bash = PrefixcommentDef.new("#"),
	python = PrefixcommentDef.new("#"),
	julia = PrefixcommentDef.new("#"),
	nix = PrefixcommentDef.new("#"),
	query = PrefixcommentDef.new(";"),
	lua = PrefixcommentDef.new("--"),
	cpp = PrefixcommentDef.new("//"),
	latex = PrefixcommentDef.new("%"),
	zig = PrefixcommentDef.new("//")
}

-- just compare two integers.
local function cmp(i1, i2)
	-- lets hope this ends up as one cmp.
	if i1 < i2 then
		return -1
	end
	if i1 > i2 then
		return 1
	end
	return 0
end

-- pos1 == pos2 => 0
-- pos1 <  pos2 => <0
-- pos1 >  pos2 => >0
local function pos_cmp(pos1, pos2)
	-- if row is different it determines result, otherwise the column does.
	return 2 * cmp(pos1[1], pos2[1]) + cmp(pos1[2], pos2[2])
end

-- ranges are end-exclusive, pos "covers" (think block cursor) pos.
local function range_includes_pos(range, pos)
	local s = { range[1], range[2] }
	local e = { range[3], range[4] }

	return pos_cmp(s, pos) <= 0 and pos_cmp(pos, e) < 0
end

-- assumption: r1 and r2 don't partially overlap, either one is included in the other, or they don't overlap.
-- return whether r1 completely includes r2.
-- r1, r2 are 4-tuple-ranges
local function range_includes_range(r1, r2)
	local s1 = { r1[1], r1[2] }
	local e1 = { r1[3], r1[4] }
	local s2 = { r2[1], r2[2] }
	local e2 = { r2[3], r2[4] }

	return pos_cmp(s1, s2) <= 0 and pos_cmp(e2, e1) <= 0
end

local range_selector = {
	shortest = function()
		local best

		return {
			record = function(new)
				if best.range == nil or range_includes_range(best.range, new.range) then
					best = new
				end
			end,
			retrieve = function()
				return best
			end
		}
	end,
	sorted = function()
		local sorted = {}

		return {
			record = function(new)
				for i = 1, #sorted do
					if range_includes_range(sorted[i].range, new.range) then
						-- ranges are before all ranges that include them =>
						-- ordered by inclusion.
						-- Obv. a non-O(n^2) sorting algorithm would be better here :D
						table.insert(sorted, i, new)
						return
					end
				end
				table.insert(sorted, new)
			end,
			retrieve = function()
				return sorted
			end
		}
	end
}

local function line_range(from, to)
	-- 0 for end seems appropriate because that is where (approximately) the
	-- comment-chars are inserted.
	-- So, if we compare this with a regular range, it would very likely!!
	-- insert its commend-end-symbol behind the line-comment-symbol of this
	-- line range.
	return {from, 0, to, 0}
end

local function fetch_lines_safe(buf, from, to, n_lines)
	if from == nil then
		print(buf, from, to)
	end
	local max_to = n_lines
	local clamped_from = math.max(from, 0)
	local clamped_to = math.min(to, max_to)
	return clamped_from, clamped_to, vim.api.nvim_buf_get_lines(buf, clamped_from, clamped_to, true)
end

local extend_factor = 1.5
local initial_range_pm = 10

---@class ToggleComment.LazyContiguousLinerange
local LazyContiguousLinerange = {}
local LazyContiguousLinerange_mt = {__index = function(t, k)
	if type(k) == "number" then
		if k < 0 or k >= t.n_lines then
			return nil
		end

		local from, to, lines
		if k < t.fetched_range_from then
			local n_required_lines = t.fetched_range_to - k
			-- prefetch a bit.
			-- This might be negative/outside the buffer range, but that's
			-- fine, we use the safe prefetch.
			local fetch_from = math.floor(t.fetched_range_to - extend_factor*n_required_lines)
			local fetch_to = t.fetched_range_from
			from, to, lines = fetch_lines_safe(0, fetch_from, fetch_to, t.n_lines)
			t.fetched_range_from = from
		elseif k >= t.fetched_range_to then
			local n_required_lines = k - t.fetched_range_from
			local fetch_to = math.ceil(t.fetched_range_from + extend_factor*n_required_lines)
			local fetch_from = t.fetched_range_to
			from, to, lines = fetch_lines_safe(0, fetch_from, fetch_to, t.n_lines)
			t.fetched_range_to = to
		end

		for i = from, to-1 do
			rawset(t, i, lines[i - from + 1])
		end
		return t[k]
	end
end}

function LazyContiguousLinerange.new(idx)
	-- ought to be enough for most comments.
	local n_lines = vim.api.nvim_buf_line_count(0)
	local from, to, lines = fetch_lines_safe(0, idx-initial_range_pm, idx+initial_range_pm, n_lines)
	local o = {}
	for i = from, to-1 do
		o[i] = lines[i - from + 1]
	end

	o.fetched_range_from = from
	o.fetched_range_to = to
	o.n_lines = n_lines
	return setmetatable(o, LazyContiguousLinerange_mt)
end

-- return range from, to-inclusive.
local function get_linecomment_range(prefix_def, buffer_lines, linenr)
	buffer_lines = LazyContiguousLinerange.new(linenr)

	local pos_linetype = prefix_def:linetype(buffer_lines[linenr])

	if pos_linetype == PrefixcommentDef.singleline then
		return linenr, linenr
	end
	if pos_linetype == nil then
		return nil, nil
	end

	local from_linenr = linenr
	local from_linetype = pos_linetype
	while true do
		if from_linetype == nil or from_linetype == PrefixcommentDef.to or from_linetype == PrefixcommentDef.singleline then
			-- line is not a connecting line, and we have not reached the
			-- `from` => this is not a comment-range.
			return nil,nil
		elseif from_linetype == PrefixcommentDef.from then
			break
		end
		from_linenr = from_linenr - 1
		if from_linenr == -1 then
			return nil,nil
		end
		from_linetype = prefix_def:linetype(buffer_lines[from_linenr])
	end

	local to_linenr = linenr
	local to_linetype = pos_linetype
	while true do
		if to_linetype == nil or to_linetype == PrefixcommentDef.from or to_linetype == PrefixcommentDef.singleline then
			return nil,nil
		elseif to_linetype == PrefixcommentDef.to then
			break
		end
		to_linenr = to_linenr + 1
		if to_linenr == buffer_lines.n_lines then
			return nil,nil
		end
		to_linetype = prefix_def:linetype(buffer_lines[to_linenr])
	end

	return from_linenr, to_linenr
end

local function uncomment_line_range(prefix_def, buffer_lines, from, to)
	for i = from, to do
		local first_non_space_col = buffer_lines[i]:find("[^%s]")
		-- if nil, this is a blank line, which is completely valid.
		if first_non_space_col then
			first_non_space_col = first_non_space_col-1
			vim.api.nvim_buf_set_text(0, i, first_non_space_col, i, first_non_space_col + prefix_def.prefix_len, {})
		end
	end
end

local function comment_line_range(prefix_def, buffer_lines, from, to)
	local from_char = from == to and prefix_def.ssingleline or prefix_def.sfrom
	for i = from, to do
		local comment_char = (i == from and from_char) or (i == to and prefix_def.sto) or prefix_def.sconnect
		print("from", comment_char == from_char)
		print("to", comment_char == prefix_def.sto)
		print("connect", comment_char == prefix_def.sconnect)
		local first_non_space_col = buffer_lines[i]:find("[^%s]")
		-- if nil, this is a blank line, which we will not comment.
		if first_non_space_col then
			first_non_space_col = first_non_space_col-1
			vim.api.nvim_buf_set_text(0, i, first_non_space_col, i, first_non_space_col, {comment_char})
		end
	end
end

---@enum ActionType
local ActionTypes = {
	comment_lines = 1,
	uncomment_lines = 2,
	nop = 3,
}

---@class RangeAction
---@field prefix_def table
---@field range integer[]
---@field type ActionType

local nop_action = {range = {}, type = ActionTypes.nop}

local function apply_action(action, buffer_lines)
	local fn = {
		[ActionTypes.comment_lines] = comment_line_range,
		[ActionTypes.uncomment_lines] = uncomment_line_range,
		[ActionTypes.nop] = util.nop,
	}
	fn[action.type](action.prefix_def, buffer_lines, action.range[1], action.range[3])
end
local function undo_action(action, buffer_lines)
	local fn = {
		[ActionTypes.comment_lines] = uncomment_line_range,
		[ActionTypes.uncomment_lines] = comment_line_range,
		[ActionTypes.nop] = util.nop,
	}
	fn[action.type](action.prefix_def, buffer_lines, action.range[1], action.range[3])
end

local last_actions = nil

local idx = 1
local function set_continuing_action(val)
	-- make copy, s.t. check below does not just check global idx!
	local current_idx = idx
	val.idx = current_idx
	last_actions = {
		val = val,
		cursor = require("util").get_cursor_0ind(),
		changedtick = vim.b.changedtick
	}

	vim.defer_fn(function()
		-- make sure we can only delete the last_toggle-val set in this call.
		if last_actions.idx == current_idx then
			-- print("removing lt " .. vim.inspect(last_toggle))
			last_actions = nil
		end
	end, 1000)

	idx = idx + 1
end

local function get_continuing_action()
	if last_actions and vim.deep_equal(last_actions.cursor, require("util").get_cursor_0ind()) and vim.b.changedtick == last_actions.changedtick then
		return last_actions.val
	end
end

return function()
	local mode = vim.fn.mode()
	if mode:sub(1,1) == "V" then
	elseif mode == "n" then
		local cursor = require("util").get_cursor_0ind()

		local buffer_lines = LazyContiguousLinerange.new(cursor[1])

		local continue_action = get_continuing_action()
		if continue_action then
			-- undo previous action.
			undo_action(continue_action.actions[continue_action.applied_action_idx], buffer_lines)

			-- find index of next action.
			continue_action.applied_action_idx = continue_action.applied_action_idx + 1
			if continue_action.applied_action_idx > #continue_action.actions then
				continue_action.applied_action_idx = 1
			end

			-- apply next action
			apply_action(continue_action.actions[continue_action.applied_action_idx], buffer_lines)

			-- allow action to continue.
			set_continuing_action(continue_action)
			return
		end

		-- get top-level parser.
		local root_parser = vim.treesitter.get_parser(0)
		if not root_parser then
			error("Could not get parser!")
		end

		-- important!!! :children returns languagetree._children directly, if we
		-- modify that table, we're in for bad recursion in languagetree:_edit :|
		local languagetrees = util.shallow_copy(root_parser:children())
		-- languagetrees only contains children of the top-level-parser, but
		-- not the top-level-parser itself => add it.
		languagetrees[root_parser:lang()] = root_parser

		local selector = range_selector.sorted()
		for lang, languagetree in pairs(languagetrees) do
			local prefix_def = lang_prefixcomment[lang]
			local line_comment_from, line_comment_to = get_linecomment_range(prefix_def, buffer_lines, cursor[1])

			if line_comment_from then
				-- line is commented, simply uncomment.
				uncomment_line_range(prefix_def, buffer_lines, line_comment_from, line_comment_to)
				-- I think if we find an uncommentable range, it should be
				-- uncommented immediately..?
				return
			end

			-- look for commentable ranges.

			local cursor_tree = languagetree:tree_for_range({
						cursor[1],
						cursor[2],
						cursor[1],
						cursor[2],
						-- we will look at the other languagetrees later.
					}, {ignore_injections = true})

			if not cursor_tree then
				goto continue;
			end

			local query = vim.treesitter.query.get(lang, "togglecomment")
			if query == nil then
				goto continue;
			end

			-- only find matches that include the cursor-line.
			for _, match, _ in query:iter_matches(cursor_tree:root(), 0, cursor[1], cursor[1]+1) do
				for id, nodes in pairs(match) do
					local name = query.captures[id]
					local node_range = {nodes[1]:range()}
					-- Since we are in line-mode, we treat the cursor as inside as long as it's on the correct line.
					local cursor_check_range = util.shallow_copy(node_range)
					cursor_check_range[2] = 0
					cursor_check_range[4] = 10000
					local node_begin_line = buffer_lines[node_range[1]]
					local node_begin_line_first_non_whitespace = node_begin_line:find("[^%s]")-1
					if
						name == "togglecomment" and
						range_includes_pos(cursor_check_range, cursor) and
						-- only allow this range as comment if 
						node_begin_line_first_non_whitespace == node_range[2] then

						selector.record({
							prefix_def = prefix_def,
							-- node_range is end-exclusive, but it excludes the
							-- last column, not the last line.
							range = line_range(node_range[1], node_range[3]),
							type = ActionTypes.comment_lines
						})
					end
				end
			end
			::continue::
		end

		local actions_range_sorted = selector.retrieve()
		if #actions_range_sorted == 0 then
			print("No toggleable node at cursor.")
			return
		end
		table.insert(actions_range_sorted, nop_action)

		apply_action(actions_range_sorted[1], buffer_lines)
		set_continuing_action({cursor = cursor, applied_action_idx = 1, actions = actions_range_sorted})
	end
end
