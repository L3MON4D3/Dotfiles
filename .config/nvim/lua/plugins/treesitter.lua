require'nvim-treesitter.configs'.setup {
	playground = {
		enable = true
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
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	indent = {
		enable = false
	}
}
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.luap = {
  install_info = {
    url = "https://github.com/vhyrro/tree-sitter-luap.git", -- local path or git repo
    files = {"src/parser.c"},
    -- optional entries:
    branch = "main", -- default branch in case of git repo if different from master
    generate_requires_npm = false, -- if stand-alone parser without npm dependencies
  },
  filetype = "luap", -- if filetype does not match the parser name
}
