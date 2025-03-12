-- removes from'th character.
local function virt_text_remove_from(complete_virt_text, from)
	local trunc_virt_text = {}

	local col = 0
	for _, virt_text in ipairs(complete_virt_text) do
		if col+#virt_text[1] > from then
			table.insert(trunc_virt_text,
				{virt_text[1]:sub(1, from-col), virt_text[2]})
			break
		else
			table.insert(trunc_virt_text, virt_text)
		end
		col = col + #virt_text[1]
		if col == from then
			break
		end
	end

	return trunc_virt_text
end
-- keeps to'th character.
-- first character is 0.
local function virt_text_remove_to_exclusive(complete_virt_text, to)
	local trunc_virt_text = {}
	-- idea: run through complete_virt_text, reject text when it is before to,
	-- and accept it if it is >=.
	-- `current_start_col` tracks the column the first character of current
	-- `virt_text` is at.
	local current_start_col = 0
	for _, virt_text in ipairs(complete_virt_text) do
		if current_start_col < to and current_start_col+#virt_text[1] > to then
			table.insert(trunc_virt_text,
				{virt_text[1]:sub(to-current_start_col+1, -1), virt_text[2]})
		else
			if current_start_col >= to then
				table.insert(trunc_virt_text, virt_text)
			end
		end
		current_start_col = current_start_col + #virt_text[1]
	end

	return trunc_virt_text
end

local function virt_text_to_string(virt_text)
	local virt_text_str = ""
	for _, v in ipairs(virt_text) do
		virt_text_str = virt_text_str .. v[1]
	end
	return virt_text_str
end

local function virt_text_contains(virt_text, str)
	-- enable plain
	return virt_text_to_string(virt_text):find(str, 1, true) ~= nil
end

local function right_pad_virt_text(virt_text, target_len)
	local current_len = vim.fn.strdisplaywidth(virt_text_to_string(virt_text))
	if target_len > current_len then
		table.insert(virt_text, {(" "):rep(target_len-current_len), "UfoFoldedFg"})
	end
	return virt_text
end

local handler = function(virtText, lnum, endLnum, width, _, ctx)
	-- important: strdisplaywidth because # doesn't account for multibyte-characters.
	local line_len = vim.fn.strdisplaywidth(virt_text_to_string(virtText))

	local fold_end_virt_text = ctx.get_fold_virt_text(endLnum)
	local suffix_virt_text = {("  %d "):format(endLnum - lnum), "DiagnosticDefaultHint"}
    local fold_virt_text
    -- I've removed ` and ctx.range.metadata.foldtext_start` from the if-condition, it shouldn't make a difference?
    if ctx.range and ctx.range.metadata then
		fold_virt_text = virt_text_remove_from(virtText, ctx.range.startCharacter)

		--[=[ if ctx.range.metadata.foldtext_start and not virt_text_contains(virtText, ctx.range.metadata.foldtext_start) then
			-- foldtext_start is on another line -> virtText probably doesn't
			-- conatin a space to separate the two.

			-- determine whether we need a space
			-- (both %W -> no, one %w, one %W -> no, both %w -> yes)
			-- (Not sure if this is the best heuristic...)
			-- scratch that: always insert a space, except if foldtext_start begins with `(`.
			-- if virtText[#virtText][1]:match("%w$") and ctx.range.metadata.foldtext_start:match("^%w") then
			-- 	table.insert(fold_virt_text, {" ", "UfoFoldedFg"})
			-- end
			if not ctx.range.metadata.foldtext_start:match("^%(") then
				table.insert(fold_virt_text, {" ", "UfoFoldedFg"})
			end
		end ]=]

		vim.list_extend(fold_virt_text, {
			{ctx.range.metadata.foldtext_start or "", ctx.range.metadata.foldtext_start_hl or ""},
			suffix_virt_text,
			{ctx.range.metadata.foldtext_end or "", ctx.range.metadata.foldtext_end_hl or ""}
		} )
		vim.list_extend(fold_virt_text, virt_text_remove_to_exclusive(fold_end_virt_text, ctx.range.endCharacter) )
	else
		-- simple case, no metadata.
		--[=[ if virtText[#virtText][1]:match("[^%w]*{%s*$") or
		   virtText[#virtText][1]:match("[^%w]*%(%s*$") then
			virtText[#virtText] = nil
		end ]=]
		table.insert(virtText, suffix_virt_text)
		fold_virt_text = virtText
    end

	-- if the actual line is longer than the virtual foldline, it will leak.
	right_pad_virt_text(fold_virt_text, line_len)

	return fold_virt_text
end



vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

local ufo = require("ufo")

local function currentBufMaxFoldLevel()
	local max_foldlevel = 0
	for i = 1, vim.api.nvim_buf_line_count(0) do
		local fl = vim.fn.foldlevel(i)
		if fl > max_foldlevel then
			max_foldlevel = fl
		end
	end

	return max_foldlevel
end

local virtFoldLevel = 99
vim.keymap.set('n', 'zR', function()
	ufo.openAllFolds()
	virtFoldLevel = currentBufMaxFoldLevel()
end)
vim.keymap.set('n', 'zM', function()
	ufo.closeAllFolds()
	virtFoldLevel = 0
end)
vim.keymap.set('n', 'zm', function()
	virtFoldLevel = virtFoldLevel-1
	require('ufo').closeFoldsWith(virtFoldLevel)
end)
vim.keymap.set('n', 'zr', function()
	virtFoldLevel = virtFoldLevel+1
	require('ufo').closeFoldsWith(virtFoldLevel)
end)

ufo.setup({
	provider_selector = function()
        return {'treesitter', 'indent'}
    end,
	open_fold_hl_timeout = 0,
	fold_virt_text_handler = handler,
	enable_get_fold_virt_text = true,
	enableFoldEndVirtText = true,
})
