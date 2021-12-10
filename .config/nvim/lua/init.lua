local ls = require("luasnip")
local s = ls.snippet
local r = ls.restore_node
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node

lspsnips = {}
-- lsp
vim.lsp.set_log_level("debug")
dap = require('dap')

local function prequire(name)
	local module_found, res = pcall(require, name)
	return module_found and res or nil
end

local function pdofile(name)
	local module_found, res = pcall(dofile, name)
	return module_found and res or {}
end

require'functions'
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
				["ac"] = "@call.outer",
				["ic"] = "@call.inner",
			},
		},
		swap = {
			enable = true,
			swap_next = {
				["<leader>>"] = "@parameter.inner",
			},
			swap_previous = {
				["<leader><"] = "@parameter.inner",
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

dap.defaults.fallback.external_terminal = {
	command = '/usr/bin/foot';
	-- footclient executes first argument.
	args = {'-Tfloatwindow'};
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
vim.fn.sign_define('DapStopped', {text=' ', texthl='GruvboxYellow', linehl='', numhl=''})

dap.configurations.cpp = {
	{
		name = "Launch",
		type = "lldb",
		request = "launch",
		program = function()
			return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
		end,
		cwd = '${workspaceFolder}',
		stopOnEntry = false,
	},
	{
		name = "Attach",
		type = "lldb",
		request = "attach",
		cwd = '${workspaceFolder}',
		pid = require('dap.utils').pick_process,
		stopOnEntry = false,
		args = {},
	},
	unpack(pdofile(".nvim_local.lua").dap or {})
}
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

local widget_entities = {
	scopes = "s",
	frames = "f",
	-- expression = "e"
}

local widget_views = {
	sidebar = "s",
	centered_float = "f",
}

dap_widgets = {}
local widgets = require("dap.ui.widgets")

for e_k, e_v in pairs(widget_entities) do
	dap_widgets[e_k] = {}
	for v_k, v_v in pairs(widget_views) do
		local widget = widgets[v_k](widgets[e_k])
		-- is opened in constructor :\
		widget.close()
		dap_widgets[e_k][v_k] = widget

		-- eg. <leader>dsf
		vim.api.nvim_set_keymap("n",
			",d"..e_v..v_v,
			"<cmd>lua dap_widgets."..e_k.."."..v_k..".toggle()<Cr>",
			{noremap=true, silent = true})
	end
end

require("dapui").setup({
	sidebar = {
		elements = { "watches" },
		position = "right"
	},
})

require("hop").setup()

-- require("lualine").setup({
-- 	options = { section_separators = {""} },
-- 	sections = {
-- 		lualine_a = {"filename"},
-- 		lualine_b = {"filetype"},
-- 	}
-- })

-- require("neogen").setup{enabled=true}

require("Comment").setup{
	toggler = {
		block = '<leader>bb',
		line = '<leader>cc'
	},
	opleader = {
		line = '<leader>c',
		block = '<leader>b'
	},
}
vim.api.nvim_set_keymap('n', '<leader>co', '<cmd>lua require("Comment.api").gco()<Cr>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>cO', '<cmd>lua require("Comment.api").gcO()<Cr>', {noremap = true})
