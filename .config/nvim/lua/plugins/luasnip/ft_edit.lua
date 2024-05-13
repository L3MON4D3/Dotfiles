-- asssumes both of these are loaded.
local snippet_collections = {
	-- lua-snippets
	{
		dir = "/home/simon/.config/nvim/luasnippets",
		extension = "lua"
	},
	{
		dir = vim.fn.getcwd() .. "/.luasnippets",
		extension = "lua"
	},
	-- snipmate-snippets
	-- this would edit snippets provided by vim-snippets.
	{
		dir = "/home/simon/.local/share/nvim/site/pack/packer/start/vim-snippets/snippets/",
		extension = "snippets"
	}
	-- vscode would be more involved
}

return function()
	require("luasnip.loaders").edit_snippet_files({
		extend = function(ft, files)
			local extend_items = {}

			for _, collection in ipairs(snippet_collections) do
				for _, file in ipairs(files) do
					if file:match(collection.dir) then
						-- a file is in personal_dir, no need to create a new file there.
						goto continue
					end
				end
				-- not continued, we need to append a new file for personal_dir
				table.insert(extend_items, {
					"New file in " .. collection.dir,
					("%s/%s.%s"):format(collection.dir, ft, collection.extension)})

				:: continue ::
			end

			return extend_items
		end,
		format = function(path, _)
			path = path:gsub(
				vim.pesc(vim.fn.stdpath("data") .. "/lazy"),
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
