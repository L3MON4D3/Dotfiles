local cmp = require'cmp'
local session = require("session")

-- require("vksnippets")
-- cannot be loaded earlier, I think.
-- TODO find a better place for this call
-- probably involves moving around packers packer_load(???).lua.
-- require("vkdoc")

-- local misc = require('cmp.utils.misc')
-- local keymap = require('cmp.utils.keymap')
-- 
-- local function merge_keymaps(base, override)
--   local normalized_base = {}
--   for k, v in pairs(base) do
--     normalized_base[keymap.normalize(k)] = v
--   end
-- 
--   local normalized_override = {}
--   for k, v in pairs(override) do
--     normalized_override[keymap.normalize(k)] = v
--   end
-- 
--   return misc.merge(normalized_base, normalized_override)
-- end
-- 
-- local mapping = setmetatable({}, {
--   __call = function(_, invoke, modes)
--     if type(invoke) == 'function' then
--       local map = {}
--       for _, mode in ipairs(modes or { 'i' }) do
--         map[mode] = invoke
--       end
--       return map
--     end
--     return invoke
--   end,
-- })
-- 
-- local cmp_default_ins = function(override)
--   return merge_keymaps(override or {}, {
--     ['<Down>'] = {
--       i = mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Select }),
--     },
--     ['<Up>'] = {
--       i = mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Select }),
--     },
--     ['<C-n>'] = {
--       i = mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Insert }),
--     },
--     ['<C-p>'] = {
--       i = mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert }),
--     },
--     ['<C-y>'] = {
--       i = mapping.confirm({ select = false }),
--     },
--     ['<C-e>'] = {
--       i = mapping.abort(),
--     },
--   })
-- end

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

vim.keymap.set("i", "<C-O>", function()
	cmp.complete({
		config = {
			sources = {
				{name = "nvim_lsp"},
				{name = "luasnip"},
				-- {name = "luasnip_choice"}
			}
		}
	})
end)
vim.keymap.set("i", "<C-F>", function()
	cmp.complete({
		config = {
			sources = {
				{name = "path"},
			}
		}
	})
end)


-- vim.keymap.set("i", "<C-S-O>", function()
-- 	cmp.complete({
-- 		config = {
-- 			sources = {
-- 				{name = "vksnippets"},
-- 			}
-- 		}
-- 	})
-- end)
