local util = require("util")

local pre_path_chars = {" ", "("}
local path_termination_chars = {" ", ":", ")"}
local row_col_separation_set = {[" "] = true, [":"] = true}

local function char_finder(forw_delimiter, backw_delimiter)
	local forw_set = util.list_to_set(forw_delimiter)
	local backw_set = util.list_to_set(backw_delimiter)

	return {
		forward = function(str, from)
			for i = from, #str do
				if forw_set[str:sub(i,i)] then
					return i
				end
			end
			return nil
		end,
		backward = function(str, from)
			for i = from, 1, -1 do
				if backw_set[str:sub(i,i)] then
					return i
				end
			end
		end
	}
end

local function get_target_file(paths, str)
	local str_abs = str
	if str:sub(1,2) == "~/" then
		str_abs = os.getenv("HOME") .. str:sub(2)
	end
	if vim.uv.fs_stat(str_abs) ~= nil then return str_abs end

	-- try all prefixes from paths.
	for _, path_prefix in ipairs(paths) do
		local path = path_prefix .. "/" .. str
		if vim.uv.fs_stat(path) ~= nil then return path end
	end
	return nil
end

local function file_location(path, row, col)
	return {
		path = path,
		row = row,
		col = col
	}
end

local function find_file_location(paths, str, col)
	local sep_finder = char_finder("/", "/")
	local path_to = sep_finder.forward(str, col) or sep_finder.backward(str, col)
	if not path_to then
		return nil
	end

	local finder = char_finder(path_termination_chars, pre_path_chars)
	-- make sure the first iteration starts looking at col.
	local path_from = col+2
	local location_path
	while true do
		local last_iteration = false
		-- -2: make sure we don't loop endlessly on one character.
		path_from = finder.backward(str, path_from-2)
		if not path_from then
			path_from = 1
			last_iteration = true
		else
			path_from = path_from+1
		end
		local tentative_path = get_target_file(paths, str:sub(path_from, path_to))
		if tentative_path ~= nil then
			location_path = tentative_path
			break
		end
		if last_iteration then
			-- can't find valid start => no path here.
			return nil
		end
	end

	-- start searching one beyond the /.
	path_to = path_to - 1
	-- here, path_from to path_to is already a valid path, now we have to try
	-- to extend it as far as possible.
	while true do
		local last_iteration = false
		-- -1: make sure we don't loop endlessly on one character.
		path_to = finder.forward(str, path_to+2)
		if not path_to then
			path_to = #str
			last_iteration = true
		else
			path_to = path_to-1
		end
		local tentative_path = get_target_file(paths, str:sub(path_from, path_to))
		if tentative_path ~= nil then
			location_path = tentative_path
			break
		end
		if last_iteration then
			-- can't find valid start => no path here.
			return nil
		end
	end

	if not (path_from <= col and col <= path_to) then
		-- this may occur if the initial path_to finds a path-separator only
		-- before col and we don't proceed past col in the second loop.
		return nil
	end
	local location_row, location_col

	-- start looking beyond path-termination-char.
	local row_start, row_end = str:find("(%d+)", path_to+2)
	if row_start == path_to+2 then
		location_row = tonumber(str:sub(row_start, row_end))

		local col_start, col_end = str:find("(%d+)", row_end+2)
		if col_start == row_end+2 and row_col_separation_set[str:sub(row_end+1, row_end+1)] then
			location_col = tonumber(str:sub(col_start, col_end))
		end
	end

	return file_location(location_path, location_row, location_col)
end

return find_file_location
