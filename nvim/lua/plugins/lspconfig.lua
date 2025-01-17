local nvim_lsp = require("lspconfig")
local util = require("util")

local lsp_attach = function(client)
	vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', 'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', 'gD', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', {noremap = true})

	vim.api.nvim_buf_set_keymap(0, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>d', '<cmd>lua vim.diagnostic.open_float()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>n', '<cmd>lua vim.lsp.buf.rename()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>ci', '<cmd>lua vim.lsp.buf.incoming_calls()<cr>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<space>co', '<cmd>lua vim.lsp.buf.outgoing_calls()<cr>', {noremap = true})

	vim.keymap.set('n', '<space>v', function()
		local conf = vim.diagnostic.config()
		vim.diagnostic.config({
			virtual_text = not conf.virtual_text,
			underline = not conf.underline
		})
	end, {noremap = true, buffer = true})
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

local session = require("session")

local function completion_intercept(client, method_cb_map)
	local orig_rpc_request = client.rpc.request
	client.rpc.request = function(method, params, handler, ...)
		local orig_handler = handler
		return orig_rpc_request(method, params, function(...)
			local err, result = ...

			if method_cb_map[method] and not err and result then
				-- method can return false to prevent
				if method_cb_map[method](result) then
					return orig_handler(...)
				end
			else
				return orig_handler(...)
			end
		end, ...)
	end
end

nvim_lsp.clangd.setup({
	cmd = {"clangd", [[--completion-style=detailed]], [[--enable-config]]},
	on_attach = function(client)
		completion_intercept(client,
		{
			["textDocument/completion"] = function(result)
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
				-- accept all completions.
				return true
			end,
			["textDocument/inlayHint"] = function(result)
				util.filter_list(result, function(item)
					   -- glm::
					if item.label == "x:" or
					   item.label == "y:" or
					   item.label == "z:" or
					   item.label == "a:" or
					   item.label == "b:" or
					   item.label == "v:" or
					   item.label == "m:" or
					   -- std::
					   item.label == "s:" or
					   item.label == "nptr:" or
					   item.label == "scalar:" or
					   item.lable == "argv0" then
						return false
					end
					-- local line = item.position.line
					-- local col = item.position.character
					-- local node = vim.treesitter.get_node({pos = {line,col}})
					-- I(vim.treesitter.get_node_text(node:parent(), 0))
					return true
				end)
				-- accept request.
				return true
			end
		})
		lsp_attach(client)
	end,
	capabilities = capabilities
})
require("clangd_extensions").setup({
	extensions = {
		inlay_hints = {
			parameter_hints_prefix = "⟵ ",
			other_hints_prefix = "⟼ ",
			highlight = "GruvboxBg1"
		}
	}
})
require("clangd_extensions.inlay_hints").setup_autocmd()
require("clangd_extensions.inlay_hints").set_inlay_hints()

nvim_lsp.texlab.setup{
	cmd = { "texlab" },
	filetypes = { "tex", "bib" },
	settings = {
		texlab = {
			build = {
				executable = "latexmk",
				args = { "-f", "-shell-escape", "-pdf", "-interaction=nonstopmode", "%f", "-synctex=1" },
				onSave = true,
				onChange = false
			},
			forwardSearch = {
				executable = "zathura",
				args = {"--synctex-forward", "%l:1:%f", "%p"},
				onSave = false
			},
			lint = {
				onChange = false,
				onSave = false
			},
			latexFormatter = "texlab"
		},
	},
	on_attach = lsp_attach,
	capabilities = capabilities
}

nvim_lsp.pyright.setup{
	capabilities = capabilities,
	on_attach = lsp_attach,
	settings = {
		python = {
			analysis = {
				autoSearchPaths = false
			}
		}
	}
}

nvim_lsp.julials.setup{
	-- cmd = {"julia", "-J", "/home/simon/.julia/sysimages/mine1.11.so", "--startup-file=no", "--project=" .. vim.fn.expand("%:p:h"), "-e", "using LanguageServer; runserver()"},
	on_attach = lsp_attach
}

nvim_lsp.cmake.setup{
	on_attach = lsp_attach
}

nvim_lsp.zls.setup{
	on_attach = function(...)
		lsp_attach(...)
	end,
	settings = {
		enable_autofix = true
	}
}

nvim_lsp.lua_ls.setup {
	cmd = {"lua-language-server", "--logpath", "/home/simon/.cache/lua-language-server/", "--metapath", "/home/simon/.cache/lua-language-server/meta/"},
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace"
			},
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
					"deps"
				}
			},
		},
	},

	on_attach = function(...)
		lsp_attach(...)
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
