vim.wo.foldlevel = 64

local render = require("ufo.render")

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
local function virt_text_remove_to(complete_virt_text, to)
	local trunc_virt_text = {}
	-- first character in virt_text.
	local col = 0
	for _, virt_text in ipairs(complete_virt_text) do
		if col < to and col+#virt_text[1] > to then
			table.insert(trunc_virt_text,
				{virt_text[1]:sub(to-col, -1), virt_text[2]})
			break
		else
			if col >= to then
				table.insert(trunc_virt_text, virt_text)
			end
		end
		col = col + #virt_text[1]
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

	local fold_virt_text
	local suffix_virt_text = {("  %d "):format(endLnum - lnum), "LspDiagnosticsDefaultHint"}
    if ctx.range and ctx.range.metadata and ctx.range.metadata.foldtext_start then
		fold_virt_text = virt_text_remove_from(virtText, ctx.range.startCharacter)

		if not virt_text_contains(virtText, ctx.range.metadata.foldtext_start) then
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
		end

		vim.list_extend(fold_virt_text, {
			{ctx.range.metadata.foldtext_start, ctx.range.metadata.foldtext_start_hl},
			suffix_virt_text,
			{ctx.range.metadata.foldtext_end, ctx.range.metadata.foldtext_end_hl}
		} )
		vim.list_extend(fold_virt_text, virt_text_remove_to(ctx.end_virt_text, ctx.range.endCharacter) )
	else
		-- simple case, no metadata.
		if virtText[#virtText][1]:match("[^%w]*{%s*$") or
		   virtText[#virtText][1]:match("[^%w]*%(%s*$") then
			virtText[#virtText] = nil
		end
		table.insert(virtText, suffix_virt_text)
		fold_virt_text = virtText
    end

	-- if the actual line is longer than the virtual foldline, it will leak.
	right_pad_virt_text(fold_virt_text, line_len)

	return fold_virt_text
end

local ufo = require("ufo")
ufo.setup({
	provider_selector = function()
        return {'treesitter', 'indent'}
    end,
	open_fold_hl_timeout = 0,
	fold_virt_text_handler = handler,
	enable_fold_end_virt_text = true
})
