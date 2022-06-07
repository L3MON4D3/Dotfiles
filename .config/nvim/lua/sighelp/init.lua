local ns_id = vim.api.nvim_create_namespace("sighelp")
local session = {}
local augroup = vim.api.nvim_create_augroup("sighelp", {})

local function to_paramstring(param_label, label)
	if type(param_label) == "table" then
		-- 0-based index in table from lsp.
		-- this will fail for some UTF16-chars.
		-- exclude end.
		return label:sub(param_label[1] + 1, param_label[2])
	else
		return param_label
	end
end

---Extract labels from sighelp-response.
---@param res response
---@return table: 
---  -active_parameter
---  -active_signature
---  -signatures: list of tables with
---    -funcname: string
---    -parameters: string[] or nil.
local function normalize(err, res)
	if err or not res then
		return nil
	end
	local clean = {}
	-- both 0-based to 1-based.
	-- default is 0.
	clean.active_parameter = (res.activeParameter or 0)+1
	clean.active_signature = (res.activeSignature or 0)+1

	-- no signatures returned.
	if #res.signatures == 0 then
		return nil
	end

	clean.signatures = {}
	for _, res_sig in ipairs(res.signatures) do
		local sig = {}
		sig.funcname = res_sig.label:match("^([^(]+)%(")

		local params = {}
		for _, param in ipairs(res_sig.parameters) do
			table.insert(params, to_paramstring(param.label, res_sig.label))
		end
		sig.parameters = #params > 0 and params or nil
		table.insert(clean.signatures, sig)
	end

	return clean
end

local function signature_to_lines(signature, width)
	local lines = {}
	lines[1] = signature.funcname .. "("
	local current_line = 1

	local function append(str, first)
		-- account for <space> when appending to the current line.
		-- no space between <funcnam>( <first>
		--                            ^ nono
		local same_line_str = (first and "" or " ") .. str
		if #lines[current_line] + #same_line_str <= width then
			lines[current_line] = lines[current_line] .. same_line_str
		else
			-- str doesn not fit inside the current line
			current_line = current_line + 1
			-- indent line and append token.
			-- #(signature.funcname .. "(")
			table.insert(lines, string.rep(" ", #signature.funcname+1) .. str)
		end
	end

	if signature.parameters then
		if #signature.parameters > 1 then
			append(signature.parameters[1] .. ",", true)
			for i=2,#signature.parameters-1 do
				append(signature.parameters[i] .. ",", false)
			end
			append(signature.parameters[#signature.parameters] .. ")", false)
		else
			append(signature.parameters[1] .. ")", true)
		end
	else
		-- signature has no parameters.
		lines[1] = lines[1] .. ")"
	end

	return lines
end

local function longest_line(lines)
	local max = 0
	for _, line in ipairs(lines) do
		if #line > max then
			max = #line
		end
	end
	return max
end

local function find_row_col(lines, str)
	for i, line in ipairs(lines) do
		-- set plain.
		local col = line:find(str, 1, true)
		if col then
			return i, col
		end
	end

	return nil,nil
end

local function highlight_param(buf, lines, label)
	-- remove old mark, if it exists.
	if session.param_mark then
		vim.api.nvim_buf_del_extmark(buf, ns_id, session.param_mark)
	end

	-- finds 1-based position.
	local l, c = find_row_col(lines, label)
	-- expects 0-based position.
	session.param_mark = vim.api.nvim_buf_set_extmark(buf, ns_id, l-1, c-1, {
		-- ends on same line, assumption? not for now, but changing
		-- signature_to_lines could invalidate it.
		end_row = l-1,
		end_col = c-1+#label,
		hl_group = "UnderlineTransparent"
	})
end

local function show_active(sig, active_param)
	local cur = vim.api.nvim_win_get_cursor(0)
	cur[1] = cur[1] - 1

	local win = vim.api.nvim_open_win(0, false, {
		relative = "cursor",
		-- width may be truncated signature_to_lines cannot be called before
		-- the window has actually been placed and the correct width can be
		-- queried.
		width = 100,
		-- adjust height later, with #signature_to_lines.
		height = 1,
		-- one below cursor.
		row = 1,
		col = 0,
		style = "minimal",
		border = {"󲕭","󲕲","󲕮","󲕳","󲕯", "󲕱", "󲕰", "󲕴"}
	})

	-- get actual, potentially truncated width:
	local width = vim.api.nvim_win_get_width(win)
	local lines = signature_to_lines(sig, width)
	-- finally set correct height.
	vim.api.nvim_win_set_config(win, {
		height = #lines,
		width = longest_line(lines)
	})
	-- multiline-indented string -> folds.
	vim.api.nvim_win_set_option(win, "foldenable", false)

	-- unlisted, scratch.
	local buf = vim.api.nvim_create_buf(false, true)
	-- set bufs filetype for (hopefully) correct highlighting.
	vim.api.nvim_buf_set_option(buf, "filetype", vim.api.nvim_buf_get_option(0, "filetype"))
	vim.api.nvim_win_set_buf(win, buf)
	vim.api.nvim_buf_set_text(buf, 0,0,0,0, lines)

	-- make sure the parameter actually exists before highlighting it.
	if sig.parameters and sig.parameters[active_param] then
		highlight_param(buf, lines, sig.parameters[active_param])
	end

	return win, buf, lines
end

local function reset_sighelp()
	-- active, close window, reset session.
	-- force-close both.
	if session.win and vim.api.nvim_win_is_valid(session.win) then
		vim.api.nvim_win_close(session.win, true)
		vim.api.nvim_buf_delete(session.buf, {force = true})
	end
	session = {}
	vim.api.nvim_clear_autocmds({
		group = augroup
	})
end

local function handler(err, res, _, _)
	local sig_res = normalize(err, res)
	if not sig_res then
		if session.win then
			reset_sighelp()
		else
			vim.notify("no sighelp here", vim.log.levels.WARN)
		end
		return
	end
	Insp(sig_res)

	local current_sig = sig_res.signatures[sig_res.active_signature]
	local current_param = sig_res.active_parameter
	if vim.deep_equal(current_sig, session.current_sig) then
		-- this signature is currently displayed! if the param also matches, there's nothing to do.
		if current_param == session.current_param then
			-- nothing to do.
			return
		end
		-- param no longer matches, update it.
		highlight_param(session.buf, session.lines, current_sig.parameters[current_param])
		session.current_param = current_param
		return
	end
	local win, buf, lines = show_active(current_sig, sig_res.active_parameter)
	-- for closing win.
	session.win = win
	-- for setting new extmark.
	session.buf = buf
	-- for finding position of parameter.
	session.lines = lines
	-- abort early if sig and active param still match.
	session.current_sig = current_sig
	session.current_param = sig_res.active_parameter
end

local function on(events, cb)
	vim.api.nvim_create_autocmd(events, {
		buffer = vim.api.nvim_get_current_buf(),
		callback = cb,
		group = augroup
	})
end

local function request_sighelp()
	vim.lsp.buf_request(0,
		 "textDocument/signatureHelp",
		 vim.tbl_extend("error",
			 vim.lsp.util.make_position_params(0),
			 { context = { triggerKind=1 } } ))
end

local function toggle()
	if session.win then
		reset_sighelp()
	else
		-- not active, make request.
		request_sighelp()
		-- make new request on CursorMovedI.
		on({"CursorMovedI"}, function() request_sighelp() end)
		-- hide on InsertLeave.
		on("InsertLeave", function() reset_sighelp() end)
	end
end

vim.lsp.handlers["textDocument/signatureHelp"] = handler

vim.keymap.set("i", "<C-H>", toggle)
