local util = require("sighelp.util")

local ls = require("luasnip")
ls.setup_snip_env()

local function sig_snipnodes(signature)
	local nodes = {}
	local indx = 1
	for _, param in ipairs(signature.parameters) do
		if param:match("pNext") then
			goto continue
		end
		vim.list_extend(nodes, {
			t"\t", i(indx, param), t{",", ""}
		})
		indx = indx + 1
		::continue::
	end
	nodes[#nodes] = t{"", ""}

	return sn(nil, nodes)
end

local function handler(err, res, _, _)
	local sig_res = util.normalize(err, res)
	if not sig_res then
		vim.notify("no sighelp here", vim.log.levels.WARN)
	end

	local choices = {}
	for i, sig in ipairs(sig_res.signatures) do
		choices[i] = sig_snipnodes(sig)
	end
	ls.snip_expand(s("", {
		t{"", ""}, c(1, choices), t")"
	}))
end

local function trigger()
	util.request_sighelp(handler)
end

vim.keymap.set("i", "<C-S-H>", trigger)
