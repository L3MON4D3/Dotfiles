vim.treesitter.language.register("bash", "PKGBUILD")

require'nvim-treesitter.configs'.setup {
	ensure_installed = {
		"rust",
		"hlsl",
		"bibtex",
		"c",
		"gitignore",
		"gitattributes",
		"bash",
		"zig",
		"make",
		"python",
		"mermaid",
		-- "jsonc",
		"json",
		"markdown",
		"dot",
		"java",
		-- "vimdoc",
		"regex",
		"luap",
		"vim",
		"toml",
		"css",
		"html",
		"julia",
		"latex",
		"nix",
		"llvm",
		"lua",
		"cpp",
		"proto"
	},
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
	},
}
