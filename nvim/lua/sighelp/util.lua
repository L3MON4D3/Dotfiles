local M = {}

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
function M.normalize(err, res)
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

function M.request_sighelp(handler)
	vim.lsp.buf_request(0,
		 "textDocument/signatureHelp",
		 vim.tbl_extend("error",
			 vim.lsp.util.make_position_params(0),
			 { context = { triggerKind=1 } } ), handler)
end


return M
