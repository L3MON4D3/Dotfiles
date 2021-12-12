local types = require("luasnip.util.types")
local helpers = require("plugins.luasnip.helpers")
local ls = require("luasnip")

ls.config.setup({
	history = true,
	updateevents = "InsertLeave",
	enable_autosnippets = false,
	region_check_events = "CursorHold",
	delete_check_events = "TextChanged,InsertEnter",
	store_selection_keys = "<Tab>",
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = {{"●", "GruvboxOrange"}},
			}
		}
	},
})

local function load_snippet_file(filename)
	-- 420 = 0644
	local fd = vim.loop.fs_open(filename, "r", 420)

	if not fd then
		return nil
	end

	local size = vim.loop.fs_fstat(fd).size
	local func_string = vim.loop.fs_read(fd, size)
	-- don't use require, we know where the file resides.
	func_string = 'dofile("/home/simon/.config/nvim/lua/plugins/luasnip/helpers.lua").setup_snip_env() ' .. func_string
	return loadstring(func_string)()
end

ls.snippets = setmetatable({}, {
	__index = function(t, k)
		-- absolute path!!!
		-- adds snip_env to the file before generating the function.
		local snippets = load_snippet_file("/home/simon/.config/nvim/lua/snippets/"..k..".lua")
		-- set to empty table if no snippets found, prevents loading the file again on the next expand.
		t[k] = snippets or {}
		return t[k]
	end
})

vim.cmd [[command! LuaSnipEdit :lua Do_nvim_relative("plugins/luasnip/helpers.lua").edit_ft()]]
vim.cmd [[
augroup snippets_clear
au!
au BufWritePost *lua/snippets/*.lua :execute 'lua require("luasnip").snippets[string.match("'.expand("<afile>").'", "/([^/]*)%.lua$")] = nil'
augroup END
]]

require("plugins.luasnip.external_update_dynamic_node")
