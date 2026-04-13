local binaries = dofile(vim.fn.stdpath("config") .. "/generated/binaries.lua")

require("conform").setup({
	formatters = {
		nixfmt = {
			command = binaries.nixfmt
		}
	},
	formatters_by_ft = {
		nix = { "nixfmt" },
	},
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})
