vim.wo.foldlevel = 64

local handler = function(virtText, lnum, endLnum, width, truncate)
    local suffix = ("  %d "):format(endLnum - lnum)
    if virtText[#virtText][1]:match("[^%w]*{%s*$") or
	   virtText[#virtText][1]:match("[^%w]*%(%s*$") then
    	virtText[#virtText] = nil
    end
    table.insert(virtText, {suffix, 'LspDiagnosticsDefaultHint'})
    return virtText
end

local ufo = require("ufo")
ufo.setup({
	provider_selector = function()
        return {'treesitter', 'indent'}
    end,
	open_fold_hl_timeout = 0,
	fold_virt_text_handler = handler
})
