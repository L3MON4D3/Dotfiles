require("flatten").setup{
	window = {
		-- open = function()
			-- -- vim.schedule(function()
				-- -- print("lvfdw ", last_valid_file_display_window)
			-- -- end)
			-- return vim.api.nvim_win_get_buf(last_valid_file_display_window), last_valid_file_display_window
		-- end
		-- open = "alternate"
		open = "smart"
	},
	block_for = {
		conf = true
	},
	-- fix for lua-dap/osv.
	-- https://github.com/willothy/flatten.nvim/issues/41
	nest_if_no_args = true
}
