local cmp = require("cmp")
local vkinfo = require("vkinfo")
local ls = require("luasnip")


local source = {}

function source.new()
	return setmetatable({}, {__index = source})
end

function source:is_available()
	return true
end

function source:get_debug_name()
	return "vksnippets"
end

local items = {}

for i, struct in ipairs(vkinfo.structs) do
	items[i] = {
		-- omit "Vk".
		word = struct.name:sub(3, -1),
		-- indent one space so it lines up with lsp-results.
		label = " " .. struct.name:sub(3, -1),
		kind = cmp.lsp.CompletionItemKind.Snippet,
		-- store index in structs, snippets are memoized in a separate table,
		-- with the same index.
		data = i
	}
end
function source:complete(_, callback)
	callback(items)
end

local function to_snippet(struct)
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
			t{",", ""}
		})

		in_indx = in_indx + 1
		::continue::
	end
	-- remove last ",":
	nodes[#nodes] = t{"", ""}

	table.insert(nodes, t"};")

	return s("", nodes)
end

local snippets = {}
function source:execute(completion_item, callback)
	local indx = completion_item.data
	if not snippets[indx] then
		snippets[indx] = to_snippet(vkinfo.structs[indx])
	end

	local cursor = vim.api.nvim_win_get_cursor(0)
	-- get_cursor returns (1,0)-indexed position, clear_region expects (0,0)-indexed.
	cursor[1] = cursor[1] - 1

	-- text cannot be cleared before, as TM_CURRENT_LINE and
	-- TM_CURRENT_WORD couldn't be set correctly.
	ls.snip_expand(snippets[indx], {
		-- clear word inserted into buffer by cmp.
		-- cursor is currently behind word.
		clear_region = {
			from = {
				cursor[1],
				cursor[2]-#completion_item.word
			},
			to = cursor
		}
	})
	callback(completion_item)
end

cmp.register_source("vksnippets", source.new())
