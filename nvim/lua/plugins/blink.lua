local cmp = require("blink.cmp")
cmp.setup{
	-- default-keybindings do weird stuff on <C-N>.
	keymap = {
		preset = 'none',
		["<C-y>"] = {'accept'}
	},
	sources = {
		cmdline = {},
		default = function()
			return {"lsp", "snippets"}
		end,
	},
	completion = {
		trigger = {
			prefetch_on_insert = false,
			show_on_keyword = false,
			show_on_trigger_character = false,
			show_on_insert_on_trigger_character = false,
			show_on_accept_on_trigger_character = false,
		},
		list = {
			selection = {auto_insert = true}
		}
	},
	snippets = {
		preset = "luasnip",
		expand = function(snip)
			local override_snip = require("session").lsp_override_snips[snip]
			if override_snip then
				require("luasnip").snip_expand(override_snip)
			else
				require("luasnip").lsp_expand(snip)
			end
		end,
	}
}

local function show_and_select(opts)
	cmp.show(opts)
	-- run cmp.select_next as soon as the window is open.
	local select_immediately_cb
	select_immediately_cb = function()
		cmp.select_next()
	require("blink.cmp.completion.windows.menu").open_emitter:off(select_immediately_cb)
	end
	require("blink.cmp.completion.windows.menu").open_emitter:on(select_immediately_cb)
end

vim.keymap.set("i", "<C-o>", function()
	cmp.show({providers = {"lsp", "snippets"}})
end)

vim.keymap.set("i", "<C-n>", function()
	if not require('blink.cmp.completion.windows.menu').win:is_open() then
		return "<C-n>"
		-- show_and_select({providers = {"buffer"}})
	else
		cmp.select_next()
	end
end, {expr=true})

vim.keymap.set("i", "<C-p>", function()
	if not require('blink.cmp.completion.windows.menu').win:is_open() then
		return "<C-p>"
		-- show_and_select({providers = {"buffer"}})
	else
		cmp.select_prev()
	end
end, {expr=true})
