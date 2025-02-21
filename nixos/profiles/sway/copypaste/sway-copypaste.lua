local Sway = require("sway")
local sway = Sway.connect()

-- helper methods
local function read(fname)
	local f = io.open(fname)
	if not f then
		return nil
	end

	local content = f:read("*all")
	f:close()
	return content
end
local function write(fname, str)
	local f = io.open(fname, "w")

	local content = f:write(str)
	f:close()
	return content
end

local function find_current_window(tree)
	if tree.focused then
		local ret = {
			id = tree.id,
			floating = tree.type == "floating_con"
		}
		return ret
	end

	for _, v in pairs(tree) do
		if type(v) == "table" then
			local id = find_current_window(v)
			if id then
				return id
			end
		end
	end
	return nil
end

local cut_con_id_file_path = "/tmp/sway_copypaste"
local function push_cut(spec)
	local stack = read(cut_con_id_file_path)
	if not stack then
		stack = ""
	end
	stack = stack .. ";" .. tostring(spec.id) .. ":" .. tostring(spec.floating)
	write(cut_con_id_file_path, stack)
end
local function pop_cut()
	local stack = read(cut_con_id_file_path)
	if not stack or stack == "" then
		return nil
	end
	-- there is at least one item on the stack.

	-- sub2: omit leading ';'
	local spec = stack:match(";[^;]+$"):sub(2)
	stack = stack:sub(1, -#spec-2)
	write(cut_con_id_file_path, stack)

	local cut_id = spec:match("(%d+):")
	local cut_floating = spec:match(":(%w+)") == "true"

	return {
		id = cut_id,
		floating = cut_floating
	}
end

if arg[1] == "cut" then
	local sway_tree = sway:getTree()
	local current_window = find_current_window(sway_tree)
	if not current_window then
		print("No active window!")
		return
	end

	push_cut(current_window)
	sway:msg("move window to scratchpad")
elseif arg[1] == "paste" then
	local cut_spec = pop_cut()
	if not cut_spec then
		print("no window-id saved in ", cut_con_id_file_path)
		return
	end
	local cut_id = cut_spec.id
	local cut_floating = cut_spec.floating

	sway:msg(("[con_id=%s] move window workspace current,, %sfocus"):format(
		cut_id,
		cut_floating and "" or "floating disable,, "))
end

