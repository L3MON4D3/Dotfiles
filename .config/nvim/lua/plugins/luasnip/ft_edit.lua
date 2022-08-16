return function()
	require("luasnip.loaders").edit_snippet_files({
		format = function(path, _)
			path = path:gsub(
				vim.pesc(vim.fn.stdpath("data") .. "/site/pack/packer/start"),
				"$PLUGINS"
			)
			if vim.env.HOME then
				path = path:gsub(vim.pesc(vim.env.HOME .. "/.config/nvim"), "$CONFIG")
			end
			path = path:gsub(vim.pesc(vim.fn.getcwd()), "$CWD")
			return path
		end,
		edit = function(file)
			vim.cmd("tabnew " .. file)
		end
	})
end
