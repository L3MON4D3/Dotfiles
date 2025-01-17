---Call cb for _all_ tables in t.
---Stop recursing further into a table if cb returns true for it.
---@param t table
---@param cb function, does some stuff. Returns whether further recursion should be aborted.
local function recursive_walk(t, cb)
	-- only inspect tables.
	if type(t) ~= "table" or cb(t) then
		return
	end
	for _, v in pairs(t) do
		recursive_walk(v, cb)
	end
end

local function find_structs(xml)
	local structs = {}
	recursive_walk(xml, function(t)
		if t[0] == "type" and t.category == "struct" then
			table.insert(structs, t)
			return true
		end
		-- keep recursing on no match.
		return false
	end)

	return structs
end

local function find_category(xml, category_name)
	local items = {}
	recursive_walk(xml, function(t)
		if t.category == category_name then
			items[t.name] = true
		end
		-- keep recursing on no match.
		return false
	end)

	return items
end

local function find_functions(xml)
	local items = {}
	recursive_walk(xml, function(t)
		if t[0] == "command" then
			if t[1] == nil and not t.alias then
				items[t.name] = true
			end
		end
		return false
	end)

	return items
end

local lxp = require("lxp.totable")
local vk_xml = io.open("/usr/share/vulkan/registry/vk.xml", "r")
p = lxp.parse(vk_xml)
lxp.clean(p)
lxp.torecord(p)

return {
	structs = find_structs(p),
	structnames = find_category(p, "struct"),
	enumnames = find_category(p, "enum"),
	handlenames = find_category(p, "handle"),
	functions = find_functions(p)
}
