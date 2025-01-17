local cmp = require'cmp'
local types = require("cmp.types")
local session = require("session")

cmp.setup {
	completion = {
		autocomplete = false,-- {cmp.TriggerEvent.TextChanged},
		completeopt = "menu,menuone,select"
	},
	snippet = {
		expand = function(args)
			local override_snip = session.lsp_override_snips[args.body]
			if override_snip then
				require("luasnip").snip_expand(override_snip)
			else
				require("luasnip").lsp_expand(args.body)
			end
		end,
	},
	mapping = {
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		-- ['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-y>'] = cmp.mapping.confirm(),
		['<C-n>'] = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Insert }),
		['<C-p>'] = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert }),
	},
	sources = cmp.config.sources({
		{name = "path"},
		{name = "luasnip"}
	}),
	window = {
		documentation = false,
	},
	experimental = {
		ghost_text = true
	},
}

vim.keymap.set("i", "<C-O>", function()
	cmp.complete({
		config = {
			sources = {
				{name = "nvim_lsp"},
				{name = "luasnip"},
			}
		}
	})
end)

vim.keymap.set("i", "<C-u>", function()
	cmp.complete({
		config = {
			sources = {
				{name = "emoji"},
			}
		}
	})
end)

vim.keymap.set("i", "<C-F>", function()
	cmp.complete({
		config = {
			sources = {
				{
					name = "path",
					option = {
						get_cwd = function(params)
							local path = {
								vim.fn.expand(('#%d:p:h'):format(params.context.bufnr)), -- default value
								vim.fn.getcwd(),
							}
							return path
						end
					},
				}
			}
		}
	})
end)
