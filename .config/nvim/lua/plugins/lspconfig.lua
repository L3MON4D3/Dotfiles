local nvim_lsp = require("lspconfig")

-- local function sem_token_attach(_)
-- 	vim.lsp.buf.semantic_tokens_full()
-- 	vim.cmd [[autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.buf.semantic_tokens_full()]]
-- end

local lsp_attach = function(client)
	vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', 'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', 'gD', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>d', '<cmd>lua vim.diagnostic.open_float()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>n', '<cmd>lua vim.lsp.buf.rename()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>v', '<cmd>lua Toggle_virtual_text()<CR>:e<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>ci', '<cmd>lua vim.lsp.buf.incoming_calls()<cr>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>co', '<cmd>lua vim.lsp.buf.outgoing_calls()<cr>', {noremap = true})

	-- require("lsp_signature").on_attach({
	-- 	always_trigger = false,
	-- 	toggle_key = "<C-S>",
	-- 	hint_enable = false,
	-- 	hi_parameter = "UnderlineTransparent"
	-- })
end

Diag_params = {signs = true, virtual_text = true}

function Toggle_virtual_text()
	Diag_params.virtual_text = not Diag_params.virtual_text
	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, Diag_params)
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, Diag_params)

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

local session = require("session")

local function completion_intercept(client, cb)
	local orig_rpc_request = client.rpc.request
	client.rpc.request = function(method, params, handler, ...)
		local orig_handler = handler
		if method == 'textDocument/completion' then
			-- Idiotic take on <https://github.com/fannheyward/coc-pyright/blob/6a091180a076ec80b23d5fc46e4bc27d4e6b59fb/src/index.ts#L90-L107>.
			handler = function(...)
				local err, result = ...

				if not err and result then
					cb(result)
				end
				return orig_handler(...)
			end
		end
		return orig_rpc_request(method, params, handler, ...)
	end
end

require("clangd_extensions").setup({
	server = {
		cmd = {"clangd", [[--completion-style=detailed]], [[--enable-config]]},
		on_attach = function(client)
			completion_intercept(client, function(result)
				local items = result.items or result
				for _, item in ipairs(items) do
					local item_text = item.textEdit.newText
					if item_text:match("^[%w_]+%(.*%)$") then
						local name = item_text:match("^[%w_]+")
						local content = item_text:match("%((.*)%)$")
						if content:match("$0") then
							content = content:gsub("$0", "$1000")
						elseif content:match("${0") then
							content = content:gsub("${0", "${1000")
						end

						ls.setup_snip_env()
						session.lsp_override_snips[item_text] = s("", {
							t(name),
							c(1, {
								{t"(", r(1, "type", ls.parser.parse_snippet(1, content)), t")"},
								{t"{", r(1, "type"), t"}"},
							})
						})
						item.insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet
					elseif item.insertTextFormat == vim.lsp.protocol.InsertTextFormat.Snippet then
						item.textEdit.newText = item_text:gsub("${0", "${100")
					end
				end
			end)
			lsp_attach(client)
			-- sem_token_attach(client)
		end,
		capabilities = capabilities
	},
	extensions = {
		inlay_hints = {
			parameter_hints_prefix = "⟵ ",
			other_hints_prefix = "⟼ ",
			highlight = "GruvboxBg1"
		}
	}
})

nvim_lsp.texlab.setup{
	cmd = { "texlab" },
	filetypes = { "tex", "bib" },
	settings = {
		texlab = {
			build = {
				executable = "latexmk",
				args = { "-f", "--shell-escape", "-pdf", "-interaction=nonstopmode", "%f" },
				onSave = true,
				onChange = false
			},
			forwardSearch = {
				args = {},
				onSave = false
			},
			lint = {
				onChange = false,
				onSave = false
			},
			latexFormatter = "texlab"
		},
	},
	on_attach = function(client)
		lsp_attach(client)
		-- sem_token_attach(client)
	end,
	capabilities = capabilities
}

nvim_lsp.pyright.setup{
	capabilities = capabilities,
	on_attach = function(client)
		lsp_attach(client)
	end,
}

nvim_lsp.julials.setup{
	cmd = {"julia", "--startup-file=no", "-e", "using LanguageServer; runserver()", "-J", "/home/simon/.julia/sysimages/mine2.so"},
	capabilities = capabilities,
	on_attach = function(client)
		lsp_attach(client)
	end,
}

nvim_lsp.cmake.setup{
	on_attach = lsp_attach
}

nvim_lsp.zls.setup{
	on_attach = function(...)
		lsp_attach(...)
	end,
}

nvim_lsp.lua_ls.setup {
	cmd = {"lua-language-server", "--logpath", "/home/simon/.cache/lua-language-server/", "--metapath", "/home/simon/.cache/lua-language-server/meta/"},
	settings = {
		Lua = {
			completion = {
				callSnippet = "Both"
			},
			capabilities = capabilities,
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = 'LuaJIT',
				path = {
					"lua/?.lua",
					"lua/?/init.lua",
					-- meta & template seem to refer to /usr/lib/lua-language-server/meta.
					"meta/template/?.lua",
					"meta/template/?/init.lua",
				}
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` and luasnip globals.
				globals = {
					"vim",
					"s",
					"sn",
					"t",
					"i",
					"f",
					"c",
					"end",
					"d",
					"isn",
					"psn",
					"l",
					"rep",
					"r",
					"p",
					"types",
					"events",
					"util",
					"fmt",
					"ls",
					"ins_generate",
					"parse",
					"parse_add",
					"s_add",
					"dl",
				},
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file("", true),
				ignoreDir = {
					".cache",
					"Packages",
					"deps"
				}
			},
		},
	},
	on_attach = function(...)
		lsp_attach(...)
		-- sem_token_attach(...)
	end,
	capabilities = capabilities
}

local rt = require("rust-tools")
rt.setup({
	server = {
		on_attach = function(client)
			lsp_attach(client)
			-- sem_token_attach(client)
		end,
		settings = {
			["rust-analyzer"] = {
				linksInHover = false
			}
		},
		capabilities = capabilities,
	}
})

nvim_lsp.cssls.setup{
	on_attach = lsp_attach
}

nvim_lsp.html.setup{
	on_attach = lsp_attach
}
