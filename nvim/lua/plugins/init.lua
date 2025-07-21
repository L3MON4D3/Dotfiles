local plugins = {
	toggleterm = "akinsho/toggleterm.nvim",
	tele_bibtex = "nvim-telescope/telescope-bibtex.nvim",
	ls_latex_snips = "iurimateus/luasnip-latex-snippets.nvim",
	editorconfig = "gpanders/editorconfig.nvim",
	eve_snippets = "evesdropper/luasnip-latex-snippets.nvim",
	luasnip = "L3MON4D3/LuaSnip",
	matchconfig = "L3MON4D3/nvim-matchconfig",
	gruvbox = "ellisonleao/gruvbox.nvim",
	dispatch = "tpope/vim-dispatch",
	fugitive = "tpope/vim-fugitive",
	lspconfig = "neovim/nvim-lspconfig",
	-- lspinstall = "kabouzeid/nvim-lspinstall",
	illuminate = "RRethy/vim-illuminate",
	cmp = "hrsh7th/nvim-cmp",
	cmp_lsp = "hrsh7th/cmp-nvim-lsp",
	cmp_luasnip = "saadparwaiz1/cmp_luasnip",
	-- cmp_ls_choice = "L3MON4D3/cmp-luasnip-choice",
	cmp_buffer = "hrsh7th/cmp-buffer",
	cmp_emoji = "hrsh7th/cmp-emoji",
	treesitter = "nvim-treesitter/nvim-treesitter",
	treesitter_textobjects = "nvim-treesitter/nvim-treesitter-textobjects",
	hop = "phaazon/hop.nvim",
	vim_glsl = "tikhomirov/vim-glsl",
	dap = "mfussenegger/nvim-dap",
	dap_py = "mfussenegger/nvim-dap-python",
	dap_ui = "rcarriga/nvim-dap-ui",
	friendly_snippets = "rafamadriz/friendly-snippets",
	plenary = "nvim-lua/plenary.nvim",
	-- playground = "nvim-treesitter/playground",
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
	oil = "stevearc/oil.nvim",
	systemd = "lilydjwg/vim-systemd-syntax",
	nvim_nio = "nvim-neotest/nvim-nio",
	-- textsubjects = "RRethy/nvim-treesitter-textsubjects"
	ssr = "cshuaimin/ssr.nvim",
	dbee = "kndndrj/nvim-dbee",
	screenkey = "NStefan002/screenkey.nvim",
	blink = "Saghen/blink.cmp",
	flatten = "willothy/flatten.nvim",
	rest = "rest-nvim/rest.nvim",
	togglecomment = "L3MON4D3/nvim-togglecomment"
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
	conf_use {
		treesitter,
		run = ":TSUpdate",
		lazy = true
	},
	conf_use{
		luasnip,
		dev = true,
		-- run = "make install_jsregexp",
		-- specify name!!
		-- just treesitter would insert the url, which is not desired here!!
		-- commit = "1def35377854535bb3b0f4cc7a33c083cdb12571",
		dependencies = {"treesitter"}
	},
	conf_use{
		matchconfig,
		dev = true
	},
	-- conf_use(ls_latex_snips),
	conf_use(jupytext),

	conf_use(gruvbox),
	use(dispatch),
	use(fugitive),
	-- conf_use {
		-- lspconfig,
		-- dependencies = {gruvbox}
	-- },
	-- use(lspinstall),
	conf_use(illuminate),

	-- conf_use {
		-- cmp,
	-- },
	conf_use{ssr},
	use(fwatch),
	-- use(cmp_lsp),
	-- use({cmp_path, commit = "1e19f86"}),
	-- use(cmp_buffer),
	-- use(cmp_ls_choice),
	-- use(cmp_sig),
	-- use {
		-- cmp_luasnip,
	-- },
	-- use(cmp_emoji),
	use(treesitter_textobjects),

	conf_use(hop),
	use(vim_glsl),
	conf_use(dap),
	conf_use{
		dap_ui,
		dependencies = {nvim_nio}
	},
	-- use(playground),
	-- use(cmp_git),

	use(github_link),
	-- conf_use(semantic_tokens)
	conf_use(comment),
	use(plenary),
	conf_use(
		da_lua
	),
	use(vrepeat),
	-- conf_use(friendly_snippets),
	-- conf_use({
	-- 	vim_snippets,
	-- }),
	conf_use(neogen),
	use(dressing),
	conf_use(telescope),
	-- conf_use(lualine),
	use(clangd),
	use(libmodal),
	conf_use(ufo),
	conf_use(catppuccin),
	use(rust_tools),
	-- use(editorconfig),
	-- use(unception),
	use(yuck),
	use(promise),
	conf_use(oil),
	conf_use(dap_py),
	conf_use(tele_bibtex),
	use(screenkey),
	conf_use({
		blink,
		version = '*'
	}),
	use(rest),
	-- conf_use{flatten, lazy=false, priority=1001}
	-- conf_use{
	-- 	dbee,
	-- 	dependencies = {
	-- 		"MunifTanjim/nui.nvim",
	-- 	},
	-- 	build = function()
	-- 		require("dbee").install()
	-- 	end,
	-- }
	-- conf_use(toggleterm),
	--use(systemd),
	-- use(eve_snippets)
	conf_use{togglecomment, dev = true}
}

-- store plugin paths in a file, so they can be easily loaded into lua-ls
-- workspace.library.
-- Make sure they are in some kind of order. This is not given naturally,
-- lazy.plugins() is not ordered at all, so we have to sort.
local function store_plugin_paths()
	local p = vim.iter(require("lazy").plugins())

	local path_by_name = p:fold({}, function(t, item)
		t[item.name] = item.dir
		return t
	end)
	local all_paths = p:map(function(item) return item.dir end):totable()

	table.sort(path_by_name)
	table.sort(all_paths)

	local data = {
		all_paths = all_paths,
		path_by_name = path_by_name
	}

    vim.fn.writefile( vim.split(("return %s"):format(vim.inspect(data)), "\n"), vim.fn.stdpath("config") .. "/generated/rtp_plugins.lua")
end

require("lazy").setup(plugin_spec, {
	dev = {
		path = "~/projects/nvim/"
	}
})

vim.api.nvim_create_autocmd({ "User" }, {
	pattern = { "LazyUpdate", "LazyInstall", "LazySync" },
	callback = function()
		-- delay a bit, make sure lazy is done with updating its stuff.
		vim.schedule(store_plugin_paths)
	end,
})

vim.api.nvim_create_user_command("StorePluginPaths", store_plugin_paths, { force = true })
