local plugins = {
	luasnip = "/home/simon/Code/Lua/luasnip",
	gruvbox = "gruvbox-community/gruvbox",
	dispatch = "tpope/vim-dispatch",
	fugitive = "tpope/vim-fugitive",
	lspconfig = "neovim/nvim-lspconfig",
	lspinstall = "kabouzeid/nvim-lspinstall",
	illuminate = "RRethy/vim-illuminate",
	cmp = "hrsh7th/nvim-cmp",
	cmp_lsp = "hrsh7th/cmp-nvim-lsp",
	cmp_luasnip = "saadparwaiz1/cmp_luasnip",
	treesitter = "nvim-treesitter/nvim-treesitter",
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
	jsregexp = "jsregexp",
	xml = "luaexpat",
	dbus = "ldbus",
	libmodal = "Iron-E/nvim-libmodal",
	impatient = "lewis6991/impatient.nvim",
	prettier = "prettier/vim-prettier",
	hydra = "anuvyklack/hydra.nvim",
	ufo = "kevinhwang91/nvim-ufo",
	promise = "kevinhwang91/promise-async",
}

local plugins_inverse = {}
for k, v in pairs(plugins) do
	plugins_inverse[v] = k
end

local packer = require("packer")

local PACKER_COMPILED_PATH = vim.fn.stdpath('cache') .. '/packer/packer_compiled.lua'

packer.startup({function(use, use_rocks)
	setfenv(1, vim.tbl_extend("force", _G or {}, plugins))

	local function conf_use(arg)
		if type(arg) == "string" then
			arg = {
				[1] = arg,
			}
		end
		arg.config = "pcall(require, \"plugins/"..plugins_inverse[arg[1]].."\")"
		use(arg)
	end

	conf_use{
		luasnip,
		requires = {
			jsregexp
		}
	}

	use(gruvbox)
	use(dispatch)
	use(fugitive)
	conf_use {
		lspconfig,
		requires = {
			luasnip,
			-- illuminate,
			cmp_lsp,
			clangd,
			--lspsig
		}
	}
	use(lspinstall)
	-- use(illuminate)

	conf_use {
		cmp,
		requires = {
			cmp_lsp,
			cmp_luasnip,
			cmp_git,
			-- cmp_sig,
			-- lsp-expand
			luasnip
		}
	}
	use(cmp_lsp)
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
	-- conf_use{
	-- 	dap_ui,
	-- 	requires = dap
	-- }
	use(playground)
	use(cmp_git)

	use(github_link)
	conf_use(semantic_tokens)
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
	use_rocks(jsregexp)
	use_rocks(xml)
	use_rocks{"dbus_proxy"}
	use(libmodal)
	use(impatient)
	conf_use{ufo, requires = promise}
	-- conf_use({hydra, requires = dap})
end,
config = {
	compile_path = PACKER_COMPILED_PATH
}})
