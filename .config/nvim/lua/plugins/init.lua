local plugins = {
	editorconfig = "gpanders/editorconfig.nvim",
	luasnip = "/home/simon/Code/Lua/luasnip",
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
	impatient = "lewis6991/impatient.nvim",
	prettier = "prettier/vim-prettier",
	hydra = "anuvyklack/hydra.nvim",
	ufo = "kevinhwang91/nvim-ufo",
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

local packer = require("packer")

local PACKER_COMPILED_PATH = vim.fn.stdpath('cache') .. '/packer/packer_compiled.lua'

local use_rocks = packer.use_rocks
packer.startup({function(use)
	setfenv(1, vim.tbl_extend("force", _G or {}, plugins))

	local function conf_use(arg)
		if type(arg) == "string" then
			arg = {
				[1] = arg,
			}
		end
		arg.config = "ok, t = pcall(require, \"plugins/"..plugins_inverse[arg[1]].."\") if not ok then print(t) end"
		use(arg)
	end

	conf_use{
		luasnip,
	}
	conf_use(jupytext)

	conf_use(gruvbox)
	use(dispatch)
	use(fugitive)
	conf_use {
		lspconfig,
		requires = {
			luasnip,
			cmp_lsp,
			clangd,
			--lspsig
		}
	}
	use(lspinstall)
	conf_use(illuminate)

	conf_use {
		cmp,
		requires = {
			cmp_lsp,
			cmp_luasnip,
			cmp_git,
			cmp_path,
			-- cmp_buffer,
			-- cmp_sig,
			-- lsp-expand
			luasnip,
			"doxnit/cmp-luasnip-choice"
		},
		commit = "cfafe0a1ca8933f7b7968a287d39904156f2c57d"
	}
	use(fwatch)
	use(cmp_lsp)
	-- use(cmp_buffer)
	-- use(cmp_sig)
	use {
		cmp_luasnip,
		requires = luasnip
	}
	conf_use {
		treesitter,
		run = ":TSUpdate",
		requires = treesitter_textobjects
	}
	use(treesitter_textobjects)

	conf_use(hop)
	use(vim_glsl)
	conf_use(dap)
	conf_use{
		dap_ui,
		requires = dap
	}
	use(playground)
	use(cmp_git)

	use(github_link)
	-- conf_use(semantic_tokens)
	conf_use(comment)
	use(plenary)
	conf_use{
		da_lua,
		requires = dap
	}
	use(vrepeat)
	conf_use({
		friendly_snippets,
		requires = luasnip
	})
	conf_use({
		vim_snippets,
		requires = luasnip
	})
	conf_use(neogen)
	use(dressing)
	use(telescope)
	conf_use(lualine)
	use(clangd)
	use_rocks{"dbus_proxy"}
	-- use_rocks("jsregexp")
	use(libmodal)
	use(impatient)
	conf_use{ufo, requires = promise}
	conf_use(catppuccin)
	use(rust_tools)
	use(editorconfig)
	use(unception)
	use(yuck)
	-- conf_use({hydra, requires = dap})
end,
config = {
	compile_path = PACKER_COMPILED_PATH
}})
