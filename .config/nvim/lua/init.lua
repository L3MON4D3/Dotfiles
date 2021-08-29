-- lsp
vim.lsp.set_log_level("debug")
dap = require('dap')

local nvim_lsp = require'lspconfig'

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

Diag_params = {signs = true, virtual_text = true}

function Toggle_virtual_text()
	Diag_params.virtual_text = not Diag_params.virtual_text
	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, Diag_params)
end

local lsp_attach = function(_)
	vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', 'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', 'gD', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<localleader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<localleader>d', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<localleader>n', '<cmd>lua vim.lsp.buf.rename()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<localleader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<localleader>v', '<cmd>lua Toggle_virtual_text()<CR>:w<CR>', {noremap = true})

	local WIDE_HEIGHT = 40
	local cmp = require'cmp'
	cmp.setup {
		completion = {
			autocomplete = false,
			completeopt = "menu,menuone,noselect"
		},
		snippet = {
			expand = function(args)
				print(args.body)
				return require("luasnip").lsp_expand(args.body)
			end,
		},
		mapping = {
			['<C-p>'] = cmp.mapping.select_prev_item(),
			['<C-n>'] = cmp.mapping.select_next_item(),
			['<C-d>'] = cmp.mapping.scroll_docs(-4),
			['<C-f>'] = cmp.mapping.scroll_docs(4),
			['<C-o>'] = cmp.mapping.complete(),
			['<C-y>'] = cmp.mapping.confirm()
		},
		sources = {
			{ name = 'nvim_lsp' },
			{ name = 'luasnip' }
		},
		documentation = {
      border = { '', '', '', ' ', '', '', '', ' ' },
      winhighlight = 'NormalFloat:CmpDocumentation,FloatBorder:CmpDocumentationBorder',
      maxwidth = math.floor((WIDE_HEIGHT * 2) * (vim.o.columns / (WIDE_HEIGHT * 2 * 16 / 9))),
      maxheight = math.floor(WIDE_HEIGHT * (WIDE_HEIGHT / vim.o.lines)),
    },
	}
end

	local cmp = require'cmp'
	cmp.setup {
		completion = {
			autocomplete = false,
			completeopt = "menu,menuone,noselect"
		},
		snippet = {
			expand = function(args)
				print(args.body)
				return require("luasnip").lsp_expand(args.body)
			end,
		},
		mapping = {
			['<C-p>'] = cmp.mapping.select_prev_item(),
			['<C-n>'] = cmp.mapping.select_next_item(),
			['<C-d>'] = cmp.mapping.scroll_docs(-4),
			['<C-f>'] = cmp.mapping.scroll_docs(4),
			['<C-o>'] = cmp.mapping.complete(),
			['<C-y>'] = cmp.mapping.confirm()
		},
		sources = {
			{ name = 'nvim_lsp' },
			{ name = 'luasnip' }
		},
	}

nvim_lsp.rust_analyzer.setup({
	on_attach = lsp_attach,
	capabilities = capabilities,
	settings = {
		["rust-analyzer"] = {
			linksInHover = false
		}
	}
})

nvim_lsp.ccls.setup{
	init_options = {
		compilationDatabaseDirectory = "build";
		highlight = {
			lsRanges = true;
		};
		index = {
			threads = 0;
		};
	};
	on_attach = lsp_attach;
	capabilities = capabilities
}

nvim_lsp.texlab.setup{
	cmd = { "texlab" },
	filetypes = { "tex", "bib" },
	settings = {
		bibtex = {
			formatting = {
				lineLength = 120
			}
		},
		latex = {
			build = {
				args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
				executable = "latexmk",
				onSave = true,
				onChange = true
			},
			forwardSearch = {
				args = {},
				onSave = false
			},
			lint = {
				onChange = false,
				onSave = true
			}
		}
	},
	on_attach = lsp_attach,
	capabilities = capabilities
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
				-- Get the language server to recognize the `vim` global
				globals = {'vim'},
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

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, Diag_params)

require'functions'
require'snips'
require'nvim-treesitter.configs'.setup {
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false
	},
	textobjects = {
		select = {
			enable = true,

			-- Automatically jump forward to textobj, similar to targets.vim 
			lookahead = true,

			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
			},
		},
		swap = {
			enable = true,
			swap_next = {
				["<leader>a"] = "@parameter.inner",
			},
			swap_previous = {
				["<leader>A"] = "@parameter.inner",
			},
		},
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]m"] = "@function.outer",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
			},
		},
	},
}
-- require "nvim-treesitter.configs".setup {
-- 	playground = {
-- 		enable = true,
-- 		disable = {},
-- 		updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
-- 		persist_queries = false, -- Whether the query persists across vim sessions
-- 		keybindings = {
-- 			toggle_query_editor = 'o',
-- 			toggle_hl_groups = 'i',
-- 			toggle_injected_languages = 't',
-- 			toggle_anonymous_nodes = 'a',
-- 			toggle_language_display = 'I',
-- 			focus_language = 'f',
-- 			unfocus_language = 'F',
-- 			update = 'R',
-- 			goto_node = '<cr>',
-- 			show_help = '?',
-- 		},
-- 	}
-- }

require'trouble'.setup({
	icons = false,
	auto_preview = false
})

dap.defaults.fallback.external_terminal = {
	command = '/usr/bin/footclient';
	-- footclient executes first argument.
	args = {'-T floatwindow '};
}
dap.defaults.fallback.force_external_terminal = true

dap.adapters.lldb = {
	type = 'executable',
	command = '/usr/bin/lldb-vscode',
	name = "lldb",
}

dap.adapters.cppdbg = {
	type = 'executable',
	command = '/usr/lib/nvim-dap-cpptools/debugAdapters/OpenDebugAD7',
	name = "vscode-cpptools",
}
dap.set_log_level("DEBUG")

vim.fn.sign_define('DapBreakpoint', {text='⛔', texthl='GruvboxRed', linehl='', numhl=''})
vim.fn.sign_define('DapStopped', {text='', texthl='GruvboxYellow', linehl='', numhl=''})

dap.configurations.cpp = {
	{
		name = "Launch",
		type = "lldb",
		request = "launch",
		program = function()
			return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
		end,
		env = {"VIMRUNTIME=/home/simon/Packages/neovim/runtime"},
		cwd = '${workspaceFolder}',
		stopOnEntry = false,
		runInTerminal = true,
	},
	{
		name = "Attach",
		type = "lldb",
		request = "attach",
		cwd = '${workspaceFolder}',
		pid = require('dap.utils').pick_process,
		stopOnEntry = false,
		args = {},
	}
}
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp
