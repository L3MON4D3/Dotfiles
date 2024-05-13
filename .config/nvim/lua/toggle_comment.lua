local lang_blockcomment = {
	lua = { [=[--[[ ]=], [=[ ]]]=] }
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

local function range_includes_pos(range, pos)
	local s = { range[1], range[2] }
	local e = { range[3], range[4] }

	return pos_cmp(s, pos) < 0 and pos_cmp(pos, e) < 0
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
		local best

		return {
			record = function(node)
				if best == nil or range_includes_range({best:range()}, {node:range()}) then
					best = node
				end
			end,
			retrieve = function()
				return best
			end
		}
	end
}

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
		else
			-- inserting at the beginning may move the end-coordinates => first insert at end, then beginning.
			vim.api.nvim_buf_set_text(0, range[3], range[4], range[3], range[4], { b_end })
			vim.api.nvim_buf_set_text(0, range[1], range[2], range[1], range[2], { b_start })
		end
	end
end

local function cursor_toggle_comment()
	local parser = vim.treesitter.get_parser()

	local cursor = require("luasnip.util.util").get_cursor_0ind()
	-- currently, the right edge of the cursor counts, so if the block-cursor
	-- is on the first character of the desired node, it won't count.
	-- We can decide to either do col+0 or col+1, the former gives us better
	-- behaviour if we're on the end of a node, the latter on the beginning.
	-- I assume that it's more likely we'll be on the beginning, so +1 it is.
	cursor[2] = cursor[2] + 1
	local languagetree = parser
			:language_for_range({
				cursor[1],
				cursor[2],
				cursor[1],
				cursor[2],
			})

	local cursor_tree = languagetree:tree_for_range({
				cursor[1],
				cursor[2],
				cursor[1],
				cursor[2],
			})


	local query = vim.treesitter.query.get(languagetree:lang(), "togglecomment")


	local selector = node_selector.shortest()

	-- start line, start col, end line, end col
	local cursor_tree_range = {cursor_tree:root():range()}
	for _, match, metadata in query:iter_matches(cursor_tree:root(), 0, cursor_tree_range[1], cursor_tree_range[3]) do
		for id, node in pairs(match) do
			local name = query.captures[id]
			if name == "togglecomment" and range_includes_pos({node:range()}, cursor) then
				selector.record(node)
			end
		end
	end

	local toggle_node = selector.retrieve()
	if not toggle_node then
		print("No toggleable node at cursor.")
		return
	end

	toggle_comment(languagetree:lang(), {toggle_node:range()})
end

return cursor_toggle_comment
