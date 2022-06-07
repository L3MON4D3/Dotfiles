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


local lxp = require("lxp.totable")
local vk_xml = io.open("/usr/share/vulkan/registry/vk.xml", "r")
p = lxp.parse(vk_xml)
lxp.clean(p)
lxp.torecord(p)

local function snip_struct(struct)
	ls.setup_snip_env()

	local nodes = {
		-- replace Vk-prefix with vk::.
		t("vk::" .. struct.name:sub(3, -1) .. " "), i(1), t{" {", ""}
	}

	local in_indx = 2
	-- skip sType and pNext (hope they are actually always at [1] and [2]...)
	for _, member in ipairs(struct) do
		if member.name == "sType" or member.name == "pNext" then
			goto continue
		end

		vim.list_extend(nodes, {
			t("\t." .. member.name .. " = "),
			i(in_indx, member.type),
			t{"", ""}
		})

		in_indx = in_indx + 1
		::continue::
	end
	table.insert(nodes, t"};")

	return s("", nodes)
end

return {
	structs = find_structs(p),
	to_snippet = snip_struct
}
