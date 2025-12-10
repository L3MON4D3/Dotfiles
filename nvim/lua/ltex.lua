local M = {}

function M.workspace_conf_path(dir)
	return ("%s/.ltex.json"):format(dir)
end

function M.get_workspace_conf(dir)
	local ok, lines = pcall(vim.fn.readfile, M.workspace_conf_path(dir))
	local conf
	if not ok then
		conf = {
			hiddenFalsePositives = {},
			dictionary = {}
		}
	else
		conf = vim.json.decode(table.concat(lines))
	end

	return conf
end

function M.set_workspace_conf(dir, conf)
	vim.fn.writefile({vim.json.encode(conf)}, M.workspace_conf_path(dir))
end

local function make_ltex_conf_lang_append_command(argkey, confkey, post_command_callback)
	return function(args, spec)
		local file_uri = args.arguments[1].uri
		local new_items = args.arguments[1][argkey]

		local client = vim.lsp.get_client_by_id(spec.client_id)
		if not client then
			error("No client!")
		end
		local workspace_path
		for _, workspace in ipairs(client.workspace_folders) do
			if file_uri:sub(1,#workspace.uri) == workspace.uri then
				workspace_path = workspace.name
			end
		end
		if not workspace_path then
			error("No workspace path!")
		end

		local conf = M.get_workspace_conf(workspace_path)

		for lang, items in pairs(new_items) do
			conf[confkey][lang] = conf[confkey][lang] or {}
			vim.list_extend(conf[confkey][lang], items)
		end
		M.set_workspace_conf(workspace_path, conf)
		post_command_callback()
	end
end



function M.register_ltex_commands(post_command_callback)
	vim.lsp.commands["_ltex.addToDictionary"] =
		make_ltex_conf_lang_append_command("words", "dictionary", post_command_callback)

	vim.lsp.commands["_ltex.hideFalsePositives"] =
		make_ltex_conf_lang_append_command("falsePositives", "hiddenFalsePositives", post_command_callback)
end

return M
