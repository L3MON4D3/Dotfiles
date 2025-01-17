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
	singleline = 4
}
PrefixcommentDef.__index = PrefixcommentDef

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
		return PrefixcommentDef.connect
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
local function pos_cmp(pos1, pos2)
	-- if row is different it determines result, otherwise the column does.
	return 2 * cmp(pos1[1], pos2[1]) + cmp(pos1[2], pos2[2])
end

local function range_includes_cursor(range, cursor_pos)
	local s = { range[1], range[2] }
	local e = { range[3], range[4] }

	-- trial and error determines this is correct.
	return pos_cmp(s, cursor_pos) < 0 and pos_cmp(cursor_pos, e) <= 0
end

-- assumption: r1 and r2 don't partially overlap, either one is included in the other, or they don't overlap.
-- return whether r1 includes r2
-- r1, r2 are 4-tuple-ranges
local function range_includes_range(r1, r2)
	local s1 = { r1[1], r1[2] }
	local e1 = { r1[3], r1[4] }
	local s2 = { r2[1], r2[2] }
	local e2 = { r2[3], r2[4] }

	return pos_cmp(s1, s2) <= 0 and pos_cmp(e2, e1) <= 0
end

local node_selector = {
	shortest = function()
		local best_range
		local best_lang

		return {
			record = function(range, lang)
				if best_range == nil or range_includes_range(best_range, range) then
					best_range = range
					best_lang = lang
				end
			end,
			retrieve = function()
				return best_range, best_lang
			end
		}
	end,
	sorted = function()
		local ranges = {}

		return {
			record = function(range, lang)
				for i = 1, #ranges do
					if range_includes_range(ranges[i][1], range) then
						-- ranges are before all ranges that include them =>
						-- ordered by inclusion.
						table.insert(ranges, i, {range,lang})
						return
					end
				end
				ranges[#ranges+1] = {range, lang}
			end,
			retrieve = function()
				return ranges
			end
		}
	end
}

local action_comment = "com"
local action_uncomment = "uncom"
local function toggle_comment(filetype, range)
	if lang_blockcomment[filetype] then
		local b_start = lang_blockcomment[filetype][1]
		local b_end = lang_blockcomment[filetype][2]
		local lines = vim.api.nvim_buf_get_text(0, range[1], range[2], range[3], range[4], {})
		-- disgusting strings.
		if lines[1]:sub(1, b_start:len()) == b_start and lines[#lines]:sub(-b_end:len(), -1) == b_end then
			-- first remove back part, then beginning.
			vim.api.nvim_buf_set_text(0, range[3], range[4]-b_end:len(), range[3], range[4], {""})
			vim.api.nvim_buf_set_text(0, range[1], range[2], range[1], range[2]+b_start:len(), {""})
			return action_uncomment, {range[1], range[2], range[3], range[4]-b_end:len() - (range[1] == range[3] and b_start:len() or 0) }
		else
			-- inserting at the beginning may move the end-coordinates => first insert at end, then beginning.
			vim.api.nvim_buf_set_text(0, range[3], range[4], range[3], range[4], { b_end })
			vim.api.nvim_buf_set_text(0, range[1], range[2], range[1], range[2], { b_start })
			return action_comment, {range[1], range[2], range[3], range[4]+b_end:len() + (range[1] == range[3] and b_start:len() or 0) }
		end
	elseif lang_prefixcomment[filetype] then
		local prefix_def = lang_prefixcomment[filetype]

		-- decide whether the range is commented, or not.
		local lines = vim.api.nvim_buf_get_lines(0, range[1], range[3]+1, true)

		-- store, for each line, the column where the first non-whitespace char
		-- occurs (0-based), or the last whitespace-character (1-based) :)
		local comment_at = {}
		for i, l in ipairs(lines) do
			-- 1-based position is next character in 0-based.
			comment_at[i] = prefix_def:comment_at_col(l)
		end

		local first_linetype = prefix_def:linetype(lines[1])

		local commented = first_linetype == PrefixcommentDef.from or first_linetype == PrefixcommentDef.singleline
		if commented then
			for i=1,#lines do
				local whitespace_end_col = comment_at[i]
				if whitespace_end_col then
					vim.api.nvim_buf_set_text(0,
						range[1]+i-1, whitespace_end_col,
						range[1]+i-1, whitespace_end_col+prefix_def.prefix_len,
						{""} )
				end
			end
			return action_uncomment, range
		else
			if range[1] == range[3] then
				-- single line
				vim.api.nvim_buf_set_text(0,
					range[1], comment_at[1],
					range[1], comment_at[1],
					{prefix_def.ssingleline} )
				return action_comment, range
			end

			-- I'll assume that the first and last line are never whitespace,
			-- think that's reasonable (if they were, they wouldn't be included
			-- in the treesitter-node, I think)
			vim.api.nvim_buf_set_text(0, range[1], comment_at[1], range[1], comment_at[1], {prefix_def.sfrom})
			for i=2,#lines-1 do
				local whitespace_end_col = comment_at[i]
				if whitespace_end_col then
					vim.api.nvim_buf_set_text(0,
						range[1]+i-1, whitespace_end_col,
						range[1]+i-1, whitespace_end_col,
						{prefix_def.sconnect})
				end
			end
			vim.api.nvim_buf_set_text(0, range[3], comment_at[#lines], range[3], comment_at[#lines], {prefix_def.sto})

			return action_comment, range
		end
	else
		print("Don't know how to block-comment filetype " .. filetype)
	end
end

local function get_prefixcommentblock(cursor, prefix_def)
	local i = cursor[1]

	local from_line = nil
	local to_line = nil


	local cline_type = prefix_def:linetype(vim.api.nvim_buf_get_lines(0, cursor[1], cursor[1]+1, true)[1])
	if cline_type == nil then
		return
	end

	if cline_type == PrefixcommentDef.singleline then
		from_line = i
		to_line = i
	else
		if cline_type == PrefixcommentDef.from then
			from_line = i
		else
			-- need to search upward to from of block.
			local current_from = i
			while true do
				current_from = current_from-1
				if current_from < 0 then
					-- not a valid prefixblockcomment
					return nil
				end
				local current_from_line_type = prefix_def:linetype(vim.api.nvim_buf_get_lines(0, current_from, current_from+1, true)[1])
				if current_from_line_type == PrefixcommentDef.from then
					break
				end
				if current_from_line_type ~= PrefixcommentDef.connect then
					return nil
				end
			end
			from_line = current_from
		end

		local last_line = vim.api.nvim_buf_line_count(0)-1
		if cline_type == PrefixcommentDef.to then
			to_line = i
		else
			-- need to search upward to from of block.
			local current_to = i
			while true do
				current_to = current_to+1
				if current_to > last_line then
					-- not a valid prefixblockcomment
					return nil
				end
				local current_to_line_type = prefix_def:linetype(vim.api.nvim_buf_get_lines(0, current_to, current_to+1, true)[1])
				if current_to_line_type == PrefixcommentDef.to then
					break
				end
				if current_to_line_type ~= PrefixcommentDef.connect then
					return nil
				end
			end
			to_line = current_to
		end
	end

	-- line-range, not a col-range.
	return {from_line, 0, to_line, 0}
end

local last_toggle = nil

local idx = 1
local function set_last_toggle(val)
	last_toggle = val
	-- make copy, s.t. check below does not just check global idx!
	local current_idx = idx
	val.idx = current_idx

	vim.defer_fn(function()
		-- make sure we can only delete the last_toggle-val set in this call.
		if last_toggle.idx == current_idx then
			-- print("removing lt " .. vim.inspect(last_toggle))
			last_toggle = nil
		end
	end, 1000)

	idx = idx + 1
end

local function cursor_toggle_comment()
	local cursor = require("util").get_cursor_0ind()

	if last_toggle and vim.deep_equal(cursor, last_toggle.cursor) then
		local used_toggle = last_toggle

		-- undo previous toggle.
		local action, new_range = toggle_comment(used_toggle.ranges[used_toggle.last_idx][2], used_toggle.ranges[used_toggle.last_idx][1])
		used_toggle.ranges[used_toggle.last_idx][1] = new_range
		used_toggle.cursor = util.get_cursor_0ind()

		if action == action_uncomment then
			local next_range_idx = used_toggle.last_idx + 1
			if next_range_idx > #used_toggle.ranges then
				next_range_idx = 1
			end

			action, new_range = toggle_comment(used_toggle.ranges[next_range_idx][2], used_toggle.ranges[next_range_idx][1])

			-- update.
			used_toggle.ranges[next_range_idx][1] = new_range
			used_toggle.last_idx = next_range_idx
			used_toggle.cursor = util.get_cursor_0ind()
		end

		set_last_toggle(used_toggle)

		return
	end

	-- currently, the right edge of the cursor counts, so if the block-cursor
	-- is on the first character of the desired node, it won't count.
	-- We can decide to either do col+0 or col+1, the former gives us better
	-- behaviour if we're on the end of a node, the latter on the beginning.
	-- I assume that it's more likely we'll be on the beginning, so +1 it is.
	cursor[2] = cursor[2] + 1

	local parser = vim.treesitter.get_parser()

	-- iterate all languages of the buffer, query them, and
	-- apply selector to all matching nodes.
	local selector = node_selector.sorted()

	-- important!!! :children returns languagetree._children directly, if we
	-- modify that table, we're in for bad recursion in languagetree:_edit :|
	local languagetrees = util.shallow_copy(parser:children())
	languagetrees[parser:lang()] = parser
	for lang, languagetree in pairs(languagetrees) do
		if lang_prefixcomment[lang] then
			local prefixcomment_range = get_prefixcommentblock(cursor, lang_prefixcomment[lang])
			if prefixcomment_range then
				selector.record(prefixcomment_range, lang)
			end
		end

		local cursor_tree = languagetree:tree_for_range({
					cursor[1],
					cursor[2],
					cursor[1],
					cursor[2],
					-- critical, so we set it here.
				}, {ignore_injections = true})

		if not cursor_tree then
			goto continue;
		end

		local query = vim.treesitter.query.get(lang, "togglecomment")
		if query == nil then
			goto continue;
		end

		-- start line, start col, end line, end col
		local cursor_tree_range = {cursor_tree:root():range()}
		-- +1: iter_matches takes line end-exclusive, cursor_tree_range is also end-exclusive, but has column-info.
		-- Just searching the beyond the end-column should not be an issue :)
		for _, match, metadata in query:iter_matches(cursor_tree:root(), 0, cursor[1], cursor_tree_range[3]+1) do
			for id, nodes in pairs(match) do
				local name = query.captures[id]
				local node_range = {nodes[1]:range()}
				if name == "togglecomment" and range_includes_cursor(node_range, cursor) then
					selector.record(node_range, lang)
				end
			end

			if metadata.togglecomment then
				selector.record(metadata.togglecomment, lang)
			end
		end

		::continue::
	end

	local ranges_langs = selector.retrieve()
	if #ranges_langs == 0 then
		print("No toggleable node at cursor.")
		return
	end

	local action, new_range = toggle_comment(ranges_langs[1][2], ranges_langs[1][1])

	-- don't do this cycle-stuff if there is only one range, I'd rather toggle
	-- the comment in that case.
	-- Also don't cycle if we uncommented, there is (I think) only ever one
	-- uncommentable range: the topmost one (TODO: think about multi-language,
	-- there we could have multiple uncomment-ranges)
	if action ~= action_uncomment and #ranges_langs > 1 then
		ranges_langs[1][1] = new_range
		local lt = { ranges = ranges_langs, last_idx = 1, cursor = util.get_cursor_0ind() }
		set_last_toggle(lt)
	end
end

return cursor_toggle_comment
