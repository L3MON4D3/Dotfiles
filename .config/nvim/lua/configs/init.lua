local conf = require("configs.config")

local proj_conf = conf.gen_config(require("configs.project_configs"))
local file_conf = conf.gen_config(require("configs.file_configs"))

-- define globally for access anywhere.
function Project_config()
	return proj_conf[vim.fn.getcwd()]
end
function File_config()
	return file_conf[vim.api.nvim_buf_get_name(0)]
end

vim.api.nvim_create_autocmd("BufRead,BufNewFile", {
	callback = function()
		File_config().run()
	end
})
vim.api.nvim_create_autocmd("BufRead,BufNewFile", {
	callback = function(args)
		-- search plain.
		if vim.fn.fnamemodify(args.file, ":p"):find(vim.fn.getcwd(), 1, true) == 1 then
			-- only run project-file-config if the buffer is inside the project-directory.
			Project_config().run_file()
		end
	end
})

Project_config().run()
