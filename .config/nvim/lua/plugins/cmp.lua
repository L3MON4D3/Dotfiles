local cmp = require'cmp'
local session = require("session")

cmp.setup {
	completion = {
		autocomplete = false,
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
	mapping = cmp.mapping.preset.insert{
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-o>'] = cmp.mapping.complete(),
		['<C-y>'] = cmp.mapping.confirm()
	},
	sources = {
		{ name = 'nvim_lsp' },
		-- { name = 'nvim_lsp_signature_help' },
		{ name = 'luasnip' },
		{ name = 'luasnip_choice' },
		{ name = 'cmp_git' },
	},
	window = {
		documentation = false,
	},
	experimental = {
		native_menu = false,
		ghost_text = true
	},
}
