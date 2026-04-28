local extra_parsers = dofile(vim.fn.stdpath("config") .. "/generated/ts_parsers.lua")

vim.treesitter.language.register("bash", "PKGBUILD")
vim.treesitter.language.add("xml", {path = "/home/simon/.config/nvim/parsers/xml/libtree-sitter-xml.so"})
vim.treesitter.language.add("wesl", {path = extra_parsers.wesl})

local langs = {
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
	"proto",
	"just",
	"wgsl"
}

require('nvim-treesitter').install(langs)

local ts_filetypes = {}
for _, lang in ipairs(langs) do
	vim.list_extend(ts_filetypes, vim.treesitter.language.get_filetypes(lang))
end

vim.api.nvim_create_autocmd('FileType', {
	pattern = ts_filetypes,
	callback = function() vim.treesitter.start() end,
})

require'nvim-treesitter-textobjects'.setup {
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
}
