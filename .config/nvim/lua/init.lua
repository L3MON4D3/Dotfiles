-- lsp

vim.lsp.set_log_level("debug")

local nvim_lsp = require'lspconfig'

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true;

Diag_params = {signs = true, virtual_text = false}

function Toggle_virtual_text()
	Diag_params["virtual_text"] = not Diag_params["virtual_text"]
	vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, Diag_params)
end

local lsp_attach = function(_)
	-- vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
	-- require'completion'.on_attach()

	vim.api.nvim_buf_set_keymap(0, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', 'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<localleader>d', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'n', '<localleader>v', '<cmd>lua Toggle_virtual_text()<CR>:w<CR>', {noremap = true})
	vim.api.nvim_buf_set_keymap(0, 'i', '<Bs>', 'pumvisible() ? "<Bs><C-X><C-O>":"<Bs>"', {noremap = false, expr = true})

	vim.g.completion_trigger_on_delete = 0
	vim.g.completion_enable_auto_hover = 0

	vim.g.completion_enable_auto_popup = 1
	vim.g.completion_enable_server_trigger = 0

	require'compe'.setup {
	 	enabled = true;
	 	autocomplete = false;
	 	debug = false;
	 	min_length = 1;
	 	preselect = 'disable';
	 	throttle_time = 80;
	 	source_timeout = 200;
	 	incomplete_delay = 400;
	 	max_abbr_width = 100;
	 	max_kind_width = 100;
	 	max_menu_width = 100;
	 	documentation = false;

		source = {
			nvim_lsp = true;
			path = false;
			buffer = false;
			calc = true;
			vsnip = false;
			nvim_lua = false;
			spell = false;
			tags = false;
			snippets_nvim = false;
			treesitter = false;
		};
	}
end

nvim_lsp.rust_analyzer.setup({
	on_attach = lsp_attach,
	capabilities = capabilities,
})

nvim_lsp.ccls.setup {
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
}

-- nvim_lsp.clangd.setup {
-- 	init_options = {
-- 		highlight = {
-- 			lsRanges = true;
-- 		};
-- 	};
-- 	on_attach = lsp_attach;
-- }

local sumneko_root_path = '/home/simon/.local/share/nvim/lspinstall/lua-language-server/'
local sumneko_binary = sumneko_root_path.."/bin/".."Linux".."/lua-language-server"

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
      },
    },
  },
  on_attach = lsp_attach,
  capabilities = capabilities
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, Diag_params)

require'snips'
-- snippets
-- local snips = require'snippets'
-- snips.snippets = {
-- 	_global = {
-- 		["("] = "($1)$0",
-- 		["{"] = "{$1}$0",
-- 		["{+"] = "{$1}$0",
-- 		["["] = "[$1]$0",
-- 		["\""] = "\"$1\"$0",
-- 		["'"] = "'$1'$0",
-- 		["test"] = "$1: $2, $3, $2"
-- 	};
-- };
-- snips.set_ux(require'snippets.inserters.floaty')
