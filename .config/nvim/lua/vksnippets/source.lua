local cmp = require("cmp")
local gen = require("vksnippets.generate")
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

for i, struct in ipairs(gen.structs) do
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

local snippets = {}
function source:execute(completion_item, callback)
	local indx = completion_item.data
	if not snippets[indx] then
		snippets[indx] = gen.to_snippet(gen.structs[indx])
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
