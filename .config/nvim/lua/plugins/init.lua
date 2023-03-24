local plugins = {
	editorconfig = "gpanders/editorconfig.nvim",
	luasnip = "L3MON4D3/LuaSnip",
	gruvbox = "ellisonleao/gruvbox.nvim",
	dispatch = "tpope/vim-dispatch",
	fugitive = "tpope/vim-fugitive",
	lspconfig = "neovim/nvim-lspconfig",
	lspinstall = "kabouzeid/nvim-lspinstall",
	illuminate = "RRethy/vim-illuminate",
	cmp = "hrsh7th/nvim-cmp",
	cmp_lsp = "hrsh7th/cmp-nvim-lsp",
	cmp_luasnip = "saadparwaiz1/cmp_luasnip",
	cmp_buffer = "hrsh7th/cmp-buffer",
	treesitter = "L3MON4D3/nvim-treesitter",
	treesitter_textobjects = "nvim-treesitter/nvim-treesitter-textobjects",
	hop = "phaazon/hop.nvim",
	vim_glsl = "tikhomirov/vim-glsl",
	dap = "mfussenegger/nvim-dap",
	dap_ui = "rcarriga/nvim-dap-ui",
	friendly_snippets = "rafamadriz/friendly-snippets",
	plenary = "nvim-lua/plenary.nvim",
	playground = "nvim-treesitter/playground",
	cmp_git = "petertriho/cmp-git",
	github_link = "knsh14/vim-github-link",
	semantic_tokens = "thehamsta/nvim-semantic-tokens",
	comment = "numToStr/Comment.nvim",
	vim_snippets = "honza/vim-snippets",
	da_lua = "jbyuki/one-small-step-for-vimkind",
	vrepeat = "tpope/vim-repeat",
	vscode_react = "dsznajder/vscode-react-javascript-snippets",
	neogen = "danymat/neogen",
	dressing = "stevearc/dressing.nvim",
	telescope = "nvim-telescope/telescope.nvim",
	lualine = "nvim-lualine/lualine.nvim",
	clangd = "p00f/clangd_extensions.nvim",
	lspsig = "ray-x/lsp_signature.nvim",
	cmp_sig = "hrsh7th/cmp-nvim-lsp-signature-help",
	cmp_path = "hrsh7th/cmp-path",
	jsregexp = "jsregexp",
	libmodal = "Iron-E/nvim-libmodal",
	prettier = "prettier/vim-prettier",
	hydra = "anuvyklack/hydra.nvim",
	ufo = "L3MON4D3/nvim-ufo",
	promise = "kevinhwang91/promise-async",
	catppuccin = "catppuccin/nvim",
	rust_tools = "simrat39/rust-tools.nvim",
	jupytext = "goerz/jupytext.vim",
	fwatch = "rktjmp/fwatch.nvim",
	unception = "samjwill/nvim-unception",
	yuck = "elkowar/yuck.vim",
}

local plugins_inverse = {}
for k, v in pairs(plugins) do
	plugins_inverse[v] = k
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

setfenv(1, vim.tbl_extend("force", _G or {}, plugins))

local function use(arg)
	if not arg then
		print(debug.traceback())
		return
	end
	if type(arg) == "string" then
		arg = {
			[1] = arg,
		}
	end
	arg.name = plugins_inverse[arg[1]]
	return arg
end
local function conf_use(arg)
	arg = use(arg)
	arg.config = function()
		local ok, err_if_not_ok = pcall(require, "plugins/"..plugins_inverse[arg[1]])
		if not ok then
			print(err_if_not_ok)
		end
	end
	return arg
end

local plugin_spec = {
	conf_use{
		luasnip,
		dev = true
	},
	conf_use(jupytext),

	conf_use(gruvbox),
	use(dispatch),
	use(fugitive),
	conf_use {
		lspconfig,
		dependencies = {gruvbox}
	},
	use(lspinstall),
	conf_use(illuminate),

	conf_use {
		cmp,
		commit = "cfafe0a1ca8933f7b7968a287d39904156f2c57d"
	},
	use(fwatch),
	use(cmp_lsp),
	-- use(cmp_buffer)
	-- use(cmp_sig)
	use {
		cmp_luasnip,
	},
	conf_use {
		treesitter,
		run = ":TSUpdate",
		lazy = true
	},
	use(treesitter_textobjects),

	conf_use(hop),
	use(vim_glsl),
	conf_use(dap),
	conf_use{
		dap_ui,
	},
	use(playground),
	use(cmp_git),

	use(github_link),
	-- conf_use(semantic_tokens)
	conf_use(comment),
	use(plenary),
	conf_use{
		da_lua,
	},
	use(vrepeat),
	conf_use{
		friendly_snippets,
	},
	conf_use({
		vim_snippets,
	}),
	conf_use(neogen),
	use(dressing),
	use(telescope),
	conf_use(lualine),
	use(clangd),
	use(libmodal),
	conf_use(ufo),
	conf_use(catppuccin),
	use(rust_tools),
	use(editorconfig),
	-- use(unception),
	use(yuck),
	use(promise)
}

require("lazy").setup(plugin_spec, {
	dev = {
		path = "~/Code/"
	}
})
