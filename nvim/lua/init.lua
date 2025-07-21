I = vim.print
Insp = vim.print

function Do_nvim_relative(filename)
	return dofile("/home/simon/.config/nvim/lua/"..filename)
end
vim.treesitter.language.register("bash", "PKGBUILD")

local repl = require("repl")

require("plugins")

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "term://*",
	callback = function(args)
		if _G._insert_term_skip then
			return
		end

		if vim.b.mode == nil then
			vim.b.mode = "i"
			vim.cmd("startinsert")
		else
			if vim.b.mode == "i" then
				vim.cmd("startinsert")
			end
		end
	end
})

vim.diagnostic.config({
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = ' ',
			[vim.diagnostic.severity.INFO] = ' ',
			[vim.diagnostic.severity.WARN] = ' ',
			[vim.diagnostic.severity.HINT] = ' '
		}
	}
})

vim.keymap.set("n", "<F11>", function()
	repl.open_unique({"bash"}, "split", true)
end, {noremap = true, silent = true})
-- F23 = S-F11.
vim.keymap.set("n", "<S-F11>", function()
	repl.open_unique({"bash"}, "vsplit", true)
end, {noremap = true, silent = true})

-- apparently $MYVIMRC already resolves to realpath.
vim.keymap.set("n", "<leader>ev", ":tabedit $MYVIMRC<Cr>:exe 'tcd'.expand('%:h')<Cr>")
local config_dir_realpath = vim.uv.fs_realpath(vim.fn.stdpath("config"))
vim.keymap.set("n", "<leader>ep", ":tabnew<Cr>:e " .. config_dir_realpath .. "/lua/plugins/<Cr>:normal gh<Cr>:tcd " .. config_dir_realpath .. "/lua/plugins/<Cr>")
vim.keymap.set("n", "<leader>sv", ":source $MYVIMRC<Cr>")

-- set EDITOR to open files in this session. Prevents nested nvim-instance.
-- vim.env.EDITOR="nvim --server " .. vim.api.nvim_get_vvar("servername") .. " --remote-tab "
-- vim.env.SYSTEMD_EDITOR="nvim --server " .. vim.api.nvim_get_vvar("servername") .. " --remote-tab "

vim.g.editorconfig = true

require("sighelp")
require("sighelp.snippet")
-- require("modes")
require("bash-scratch")
require("write")
require("filejump")

-- vim.treesitter.query.add_directive("set_injection_filetype_snippet_file!", function(_, _, bufnr, _, metadata)
-- 	local name = vim.api.nvim_buf_get_name(bufnr)
-- 	-- get file-basename.
-- 	metadata.language = vim.fn.fnamemodify(name, ":t:r")
-- 	return true
-- end )

vim.treesitter.language.add("xml", {path = "/home/simon/.config/nvim/parsers/xml/libtree-sitter-xml.so"})

-- mappings and commands
vim.api.nvim_create_user_command("O", function()
	vim.api.nvim_input(":tabnew<Cr>:e ~/Documents/base<Cr>:normal gh<Cr>")
end, {})

vim.api.nvim_create_user_command("P", function()
	local fname = vim.api.nvim_buf_get_name(0)
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.fn.setreg("", fname .. ":" .. row)
end, {})

-- predicate used by lua/togglecomment.scm
vim.treesitter.query.add_predicate("root-child", function(match, _, _, predicate)
	local node = match[predicate[2]]
	return node[#node]:parent():parent() == nil
end, {})

-- #set-from-nodetext! target node [[pattern replacement] [pattern replacement] ... ]
-- (gsubs are optional)
vim.treesitter.query.add_directive("set-from-nodetext-gsub!", function(match, pattern, source, predicate, metadata)
	local node = match[predicate[3]]
	local text = vim.treesitter.get_node_text(node, source, metadata)

	-- apply all gsubs
	local gsub_args_start = 4
	while predicate[gsub_args_start] and predicate[gsub_args_start+1] do
		text = text:gsub(predicate[gsub_args_start], predicate[gsub_args_start+1])
		gsub_args_start = gsub_args_start + 2
	end

	metadata[predicate[2]] = text
end, {})

vim.treesitter.query.add_directive("make-range-extended!", function(match, pattern, source, pred, metadata)
	-- extract node-ranges
	local r1 = {match[pred[3]]:range()}
	local r2 = {match[pred[7]]:range()}

	-- extract correct positions
	local p1 = pred[4] == "end_" and {r1[3], r1[4]} or {r1[1], r1[2]}
	local p2 = pred[8] == "end_" and {r2[3], r2[4]} or {r2[1], r2[2]}

	-- apply offsets.
	p1[1] = p1[1] + pred[5]
	p1[2] = p1[2] + pred[6]
	p2[1] = p2[1] + pred[9]
	p2[2] = p2[2] + pred[10]

	metadata[pred[2]] = {p1[1], p1[2], p2[1], p2[2]}
end, {})

vim.treesitter.query.add_directive("make-range2!", function(match, pattern, source, pred, metadata)
	local r1 = {match[pred[3]]:range()}
	local r2 = {match[pred[4]]:range()}
	metadata[pred[2]] = {r1[1], r1[2], r2[3], r2[4]}
end, {})
