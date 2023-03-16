local M = {}

local function get_min_indent(lines)
	-- "^(%s*)%S": match only lines that actually contain text.
	local min_indent = lines[1]:match("^(%s*)%S")
	for i = 2, #lines do
		-- %s* -> at least matches
		local line_indent = lines[i]:match("^(%s*)%S")
		-- ignore if not matched.
		if line_indent then
			-- if no line until now matched, use line_indent.
			if not min_indent or #line_indent < #min_indent then
				min_indent = line_indent
			end
		end
	end
	return min_indent
end

local function byte_start_to_byte_end(pos)
	local line = vim.api.nvim_buf_get_lines(0, pos[1], pos[1] + 1, false)
	-- line[1]: get_lines returns table.
	-- col may be one past the end (for linebreak)
	-- byteindex rounds toward end of the multibyte-character.
	return vim.str_byteindex(
		line[1] .. " " or "",
		vim.str_utfindex(line[1] .. " " or "", pos[2])
	)
end

function M.get_visual()
	local start_line, start_col = vim.fn.line("'<"), vim.fn.col("'<")
	Insp({start_line, start_col})

	local end_line = vim.fn.line("'>")
	print(end_line)
	-- col of '>/'< is the first byte, in case of multibyte. As the entire
	-- multibyte-string has to be in the selection, this needs to be converted.
	local end_col = byte_start_to_byte_end({ end_line - 1, vim.fn.col("'>") })
	print(end_col)

	local mode = vim.fn.visualmode()
	if
		not vim.o.selection == "exclusive"
		and not (start_line == end_line and start_col == end_col)
	then
		end_col = end_col - 1
	end

	local chunks = {}
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, true)
	if start_line == end_line then
		chunks = { lines[1]:sub(start_col, end_col) }
	else
		local first_col = 0
		local last_col = nil
		if mode:lower() ~= "v" then -- mode is block
			first_col = start_col
			last_col = end_col
		end
		chunks = { lines[1]:sub(start_col, last_col) }

		-- potentially trim lines (Block).
		for cl = 2, #lines - 1 do
			table.insert(chunks, lines[cl]:sub(first_col, last_col))
		end
		table.insert(chunks, lines[#lines]:sub(first_col, end_col))
	end

	-- init with raw selection.
	local tm_select, select_dedent = vim.deepcopy(chunks), vim.deepcopy(chunks)
	-- may be nil if no indent.
	local min_indent = get_min_indent(lines) or ""
	-- TM_SELECTED_TEXT contains text from new cursor position(for V the first
	-- non-whitespace of first line, v and c-v raw) to end of selection.
	if mode == "V" then
		tm_select[1] = tm_select[1]:gsub("^%s+", "")
		-- remove indent from all lines:
		for i = 1, #select_dedent do
			select_dedent[i] = select_dedent[i]:gsub("^" .. min_indent, "")
		end
	elseif mode == "v" then
		-- if selection starts inside indent, remove indent.
		if #min_indent > start_col then
			select_dedent[1] = lines[1]:gsub(min_indent, "")
		end
		for i = 2, #select_dedent - 1 do
			select_dedent[i] = select_dedent[i]:gsub(min_indent, "")
		end

		-- remove as much indent from the last line as possible.
		if #min_indent > end_col then
			select_dedent[#select_dedent] = ""
		else
			select_dedent[#select_dedent] =
				select_dedent[#select_dedent]:gsub("^" .. min_indent, "")
		end
	else
		-- in block: if indent is in block, remove the part of it that is inside
		-- it for select_dedent.
		if #min_indent > start_col then
			local indent_in_block = min_indent:sub(start_col, #min_indent)
			for i, line in ipairs(chunks) do
				select_dedent[i] = line:gsub("^" .. indent_in_block, "")
			end
		end
	end

	return select_dedent
end

return M
