local ls = require("luasnip")
local util = require("luasnip.util.util")

local function find_dynamic_node(node)
	while not node.dynamicNode do
		node = node.parent
	end
	return node.dynamicNode
end

local external_update_id = 0
local function dynamic_node_external_update(func_indx)
	local current_node = ls.session.current_nodes[vim.api.nvim_get_current_buf()]
	local dynamic_node = find_dynamic_node(current_node)

	-- to identify current node in new snippet, if it is available.
	external_update_id = external_update_id + 1
	current_node.external_update_id = external_update_id

	local insert_pre_cc = vim.fn.mode() == "i"
	-- is byte-indexed! Doesn't matter here, but important to be aware of.
	local cursor_pos_pre_relative = util.pos_sub(
		util.get_cursor_0ind(),
		current_node.mark:pos_begin_raw()
	)

	if dynamic_node.snip then
		dynamic_node.snip:store()
		-- tear down current snippet.
		dynamic_node.snip:input_leave()
	end

	-- call update-function.
	local func = dynamic_node.user_args[func_indx]
	if func then
		func(dynamic_node.parent)
	end

	dynamic_node:update()

	local target_node = dynamic_node:find_node(function(test_node)
		return test_node.external_update_id == external_update_id
	end)

	if target_node then
		-- the node that the cursor was in when changeChoice was called exists
		-- in the active choice! jump_into it!
		--
		-- if in INSERT before change_choice, don't actually move into the node.
		-- The new cursor will be set to the actual edit-position later.
		local jump_node = dynamic_node.snip:jump_into(1, insert_pre_cc)

		local jumps = 1
		while jump_node ~= target_node do
			jump_node = jump_node:jump_from(1, insert_pre_cc)

			-- just for testing...
			if jumps > 1000 then
				print("FAIL! Too many jumps!!")
				ls.session.current_nodes[vim.api.nvim_get_current_buf()] = dynamic_node.snip:jump_into(1)
				return
			end
			jumps = jumps + 1
		end
		if insert_pre_cc then
			util.set_cursor_0ind(
				util.pos_add(
					target_node.mark:pos_begin_raw(),
					cursor_pos_pre_relative
				)
			)
		end
		ls.session.current_nodes[vim.api.nvim_get_current_buf()] = jump_node
	else
		ls.session.current_nodes[vim.api.nvim_get_current_buf()] = dynamic_node.snip:jump_into(1)
	end
end

local esc = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

vim.api.nvim_set_keymap('i', "<C-t>", '<cmd>lua require("plugins.luasnip.external_update_dynamic_node").dynamic_node_external_update(1)<Cr>', {noremap = true})
vim.api.nvim_set_keymap('s', "<C-t>", '<cmd>lua require("plugins.luasnip.external_update_dynamic_node").dynamic_node_external_update(1)<Cr>', {noremap = true})

vim.api.nvim_set_keymap('i', "<C-g>", '<cmd>lua require("plugins.luasnip.external_update_dynamic_node").dynamic_node_external_update(2)<Cr>', {noremap = true})
vim.api.nvim_set_keymap('s', "<C-g>", '<cmd>lua require("plugins.luasnip.external_update_dynamic_node").dynamic_node_external_update(2)<Cr>', {noremap = true})

return {
	dynamic_node_external_update = dynamic_node_external_update
}
