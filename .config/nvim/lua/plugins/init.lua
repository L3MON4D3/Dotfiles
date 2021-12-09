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
	-- friendly_snippets = "rafamadriz/friendly-snippets",
	-- plenary = "nvim-lua/plenary.nvim",
	-- popup = "nvim-lua/popup.nvim",
	playground = "nvim-treesitter/playground",
	cmp_git = "petertriho/cmp-git",
	github_link = "knsh14/vim-github-link",
	semantic_tokens = "thehamsta/nvim-semantic-tokens",
	comment = "numToStr/Comment.nvim",
}

local plugins_reverse = {}
for k, v in pairs(plugins) do
	plugins_reverse[v] = k
end


return require("packer").startup(function(use)
	setfenv(1, setmetatable(plugins, {
		__index = _G
	}))

	local function conf_use(arg)
		if type(arg) == "string" then
			arg = {
				[1] = arg,
			}
		end
		arg.config = "require \"plugins/"..plugins_reverse[arg[1]].."\""
		use(arg)
	end

	conf_use(luasnip)

	use(gruvbox)
	use(dispatch)
	use(fugitive)
	conf_use { lspconfig,
		requires = {
			luasnip,
			illuminate,
			cmp_lsp
		}
	}
	use(lspinstall)
	use(illuminate)
	
	use(cmp)
	use {
		cmp_lsp,
		requires = cmp
	}
	use(cmp_luasnip)
	use {
		treesitter,
		run = ":TSUpdate",
	}
	use(treesitter_textobjects)

	use(hop)
	use(vim_glsl)
	use(dap)
	use(dap_ui)
	use(playground)
	use(cmp_git)

	use(github_link)
	conf_use(semantic_tokens)
	use(comment)
end)
