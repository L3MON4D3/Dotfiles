local nvim_lsp = require("lspconfig")


local function sem_token_attach(client)
	if client.resolved_capabilities.semantic_tokens_full then
		vim.lsp.buf.semantic_tokens_full()
		vim.cmd [[autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.buf.semantic_tokens_full()]]
	end
end

local lsp_attach = function(client)
	vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', 'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', 'gD', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>d', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>n', '<cmd>lua vim.lsp.buf.rename()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>v', '<cmd>lua Toggle_virtual_text()<CR>:w<CR>', {noremap = true})


	-- require 'illuminate'.on_attach(client)
end

Diag_params = {signs = true, virtual_text = true}

function Toggle_virtual_text()
	Diag_params.virtual_text = not Diag_params.virtual_text
	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, Diag_params)
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, Diag_params)

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

local ls_helper = require("plugins.luasnip.helpers")
local session = require("session")

nvim_lsp.clangd.setup{
	on_attach = function(client)
		lsp_attach(client)
		sem_token_attach(client)

		local orig_rpc_request = client.rpc.request
		function client.rpc.request(method, params, handler, ...)

			local orig_handler = handler
			if method == 'textDocument/completion' then
				-- Idiotic take on <https://github.com/fannheyward/coc-pyright/blob/6a091180a076ec80b23d5fc46e4bc27d4e6b59fb/src/index.ts#L90-L107>.
				handler = function(...)
					ls_helper.setup_snip_env()
					local err, result = ...
					if not err and result then
						local items = result.items or result
						for _, item in ipairs(items) do
							if item.textEdit.newText:match("^[%w_]+%(.*%)$") then

								local snip_text = item.textEdit.newText
								local name = snip_text:match("^[%w_]+")
								local content = snip_text:match("%((.*)%)$")
								if content:match("$0") then
									content = content:gsub("$0", "$1000")
								elseif content:match("${0") then
									content = content:gsub("${0", "${1000")
								end

								session.lsp_override_snips[snip_text] = s("", {
									t(name),
									c(1, {
										{t"(", r(1, "type", ls.parser.parse_snippet(1, content)), t")"},
										{t"{", r(1, "type"), t"}"},
									})
								})
							end
							item.insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet
						end
					end
					return orig_handler(...)
				end
			end
			return orig_rpc_request(method, params, handler, ...)
		end
	end,
	capabilities = capabilities
}

nvim_lsp.texlab.setup{
	cmd = { "texlab" },
	filetypes = { "tex", "bib" },
	settings = {
		texlab = {
			build = {
				executable = "latexmk",
				args = { "-f", "-shell-escape", "-pdf", "-interaction=nonstopmode", "%f" },
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
		sem_token_attach(client)
	end,
	capabilities = capabilities
}

require'lspconfig'.pyright.setup{
	capabilities = capabilities,
	on_attach = function(client)
		lsp_attach(client)
		sem_token_attach(client)
	end,
}

require'lspconfig'.julials.setup{
	cmd = {"julia", "--startup-file=no", "-e using LanguageServer; runserver()", "-J/home/simon/.julia/sysimages/GLMakieImage.so"},
	capabilities = capabilities,
	on_attach = function(client)
		lsp_attach(client)
		sem_token_attach(client)
	end,
}

local sumneko_root_path = '/home/simon/.local/share/nvim/lspinstall/lua-language-server/'
local sumneko_binary = sumneko_root_path.."/bin/Linux/lua-language-server"

nvim_lsp.sumneko_lua.setup {
	cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
	settings = {
		Lua = {
			capabilities = capabilities,
			runtime = {
				-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
				version = 'LuaJIT',
				-- Setup your lua path
				path = vim.split(package.path, ';'),
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
					"parse"
				},
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = {
					[vim.fn.expand('$VIMRUNTIME/lua')] = true,
					[vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
				},
				ignoreDir = {
					"/home/simon/Packages"
				}
			},
		},
	},
	on_attach = lsp_attach,
	capabilities = capabilities
}

nvim_lsp.rust_analyzer.setup({
	capabilities = capabilities,
	settings = {
		["rust-analyzer"] = {
			linksInHover = false
		}
	},
	on_attach = function(client)
		lsp_attach(client)
		sem_token_attach(client)
	end,
})
