local cmp = require'cmp'
local session = require("session")

require("vksnippets")
-- cannot be loaded earlier, I think.
-- TODO find a better place for this call
-- probably involves moving around packers packer_load(???).lua.
require("vkdoc")

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
		['<C-y>'] = cmp.mapping.confirm(),
	},
	window = {
		documentation = false,
	},
	experimental = {
		native_menu = false,
		ghost_text = true
	},
}

vim.cmd[[
inoremap <C-O> <cmd>lua require("cmp").complete({config = {sources = {{name = "nvim_lsp"}} } })<Cr>
inoremap <C-S-O> <cmd>lua require("cmp").complete({config = {sources = {{name = "vksnippets"}} } })<Cr>
]]
