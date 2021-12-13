local ls = require("luasnip")
local util = require("luasnip.util.util")

local function find_dynamic_node(node)
	while not node.dynamicNode do
		node = node.parent
	end
	return node.dynamicNode
end

local external_update_id = 0
-- func_indx to update the dynamicNode with different functions.
local function dynamic_node_external_update(func_indx)
	-- find current node and the innermost dynamicNode it is inside.
	local current_node = ls.session.current_nodes[vim.api.nvim_get_current_buf()]
	local dynamic_node = find_dynamic_node(current_node)

	-- to identify current node in new snippet, if it is available.
	external_update_id = external_update_id + 1
	current_node.external_update_id = external_update_id

	-- store which mode we're in to restore later.
	local insert_pre_call = vim.fn.mode() == "i"
	-- is byte-indexed! Doesn't matter here, but important to be aware of.
	local cursor_pos_pre_relative = util.pos_sub(
		util.get_cursor_0ind(),
		current_node.mark:pos_begin_raw()
	)

	-- store and leave current generated snippet.
	dynamic_node.snip:store()
	dynamic_node.snip:input_leave()

	-- call update-function.
	local func = dynamic_node.user_args[func_indx]
	if func then
		-- the same snippet passed to the dynamicNode-function. Any output from func
		-- should be stored in it under some unused key.
		func(dynamic_node.parent)
	end

	dynamic_node:update()

	-- everything below here isn't strictly necessary, but it's pretty nice to have.


	-- try to find the node we marked earlier.
	local target_node = dynamic_node:find_node(function(test_node)
		return test_node.external_update_id == external_update_id
	end)

	if target_node then
		-- the node that the cursor was in when changeChoice was called exists
		-- in the new snippet! jump_into it!
		--
		-- if in INSERT before call, don't actually move into the node.
		-- The new cursor will be set to the actual edit-position later.
		local jump_node = dynamic_node.snip:jump_into(1, insert_pre_call)

		-- jump until the target_node was jump_into'ed.
		-- It isn't as clean to just jump into the target_node, as all the events
		-- wouldn't be triggered.
		while jump_node ~= target_node do
			jump_node = jump_node:jump_from(1, insert_pre_call)
		end
		if insert_pre_call then
			-- we were in INSERT before the call, set the cursor to the correct position.
			util.set_cursor_0ind(
				util.pos_add(
					target_node.mark:pos_begin_raw(),
					cursor_pos_pre_relative
				)
			)
		end
		-- set the new current node correctly.
		ls.session.current_nodes[vim.api.nvim_get_current_buf()] = jump_node
	else
		-- the marked node wasn't found, just jump into the new snippet noremally.
		ls.session.current_nodes[vim.api.nvim_get_current_buf()] = dynamic_node.snip:jump_into(1)
	end
end

vim.api.nvim_set_keymap('i', "<C-t>", '<cmd>lua require("plugins.luasnip.external_update_dynamic_node").dynamic_node_external_update(1)<Cr>', {noremap = true})
vim.api.nvim_set_keymap('s', "<C-t>", '<cmd>lua require("plugins.luasnip.external_update_dynamic_node").dynamic_node_external_update(1)<Cr>', {noremap = true})

vim.api.nvim_set_keymap('i', "<C-g>", '<cmd>lua require("plugins.luasnip.external_update_dynamic_node").dynamic_node_external_update(2)<Cr>', {noremap = true})
vim.api.nvim_set_keymap('s', "<C-g>", '<cmd>lua require("plugins.luasnip.external_update_dynamic_node").dynamic_node_external_update(2)<Cr>', {noremap = true})

return {
	dynamic_node_external_update = dynamic_node_external_update
}
