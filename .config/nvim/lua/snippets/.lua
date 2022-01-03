local function jdocsnip(args, _, old_state)
	local nodes = {
		t({"/**"," * "}),
		old_state and i(1, old_state.descr:get_text()) or i(1, {"A short Description"}),
		t({"", ""})
	}

	-- These will be merged with the snippet; that way, should the snippet be updated,
	-- some user input eg. text can be referred to in the new snippet.
	local param_nodes = {
		descr = nodes[2]
	}

	-- At least one param.
	if string.find(args[2][1], " ") then
		vim.list_extend(nodes, {t({" * ", ""})})
	end

	local insert = 2
	for indx, arg in ipairs(vim.split(args[2][1], ", ", true)) do
		-- Get actual name parameter.
		arg = vim.split(arg, " ", true)[2]
		if arg then
			arg = arg:gsub(",", "")
			local inode
			-- if there was some text in this parameter, use it as static_text for this new snippet.
			if old_state and old_state["arg"..arg] then
				inode = i(insert, old_state["arg"..arg]:get_text())
			else
				inode = i(insert)
			end
			vim.list_extend(nodes, {t({" * @param "..arg.." "}), inode, t({"", ""})})
			param_nodes["arg"..arg] = inode

			insert = insert + 1
		end
	end

	if args[1][1] ~= "void" then
		local inode
		if old_state and old_state.ret then
			inode = i(insert, old_state.ret:get_text())
		else
			inode = i(insert)
		end

		vim.list_extend(nodes, {t({" * ", " * @return "}), inode, t({"", ""})})
		param_nodes.ret = inode
		insert = insert + 1
	end

	if vim.tbl_count(args[3]) ~= 1 then
		local exc = string.gsub(args[3][2], " throws ", "")
		local ins
		if old_state and old_state.ex then
			ins = i(insert, old_state.ex:get_text())
		else
			ins = i(insert)
		end
		vim.list_extend(nodes, {t({" * ", " * @throws "..exc.." "}), ins, t({"", ""})})
		param_nodes.ex = ins
		insert = insert + 1
	end

	vim.list_extend(nodes, {t({" */"})})

	local snip = sn(nil, nodes)
	-- Error on attempting overwrite.
	snip.old_state = param_nodes
	return snip
end

return {
	s("lel", i(1, "lal")),
	parse("lol", "a${1:$TM_CURRENT_LINE}"),
	s({trig="fn"}, {
		d(6, jdocsnip, {ai[2], ai[4], ai[5]}), t({"", ""}),
		c(1, {
			t({"public "}),
			t({"private "})
		}),
		c(2, {
			t({"void"}),
			i(nil, {""}),
			t({"String"}),
			t({"char"}),
			t({"int"}),
			t({"double"}),
			t({"boolean"}),
		}),
		t({" "}),
		i(3, {"myFunc"}),
		t({"("}), i(4), t({")"}),
		c(5, {
			t({""}),
			sn(nil, {
				t({""," throws "}),
				i(1)
			})
		}),
		t({" {", "\t"}),
		i(0),
		t({"", "}"})
	}),
	s("test", {
		t"b",
		i(1),
		c(2, {
			t"aaa",
			f(function(args) return args[1] end, 1)
		}), t" : ",
		rep(1)
	}),
	-- s("test2", {
	-- 	i(1),
	-- 	t" : ",
	-- 	f(function(args) return args[1][1]..args[2][1] end, {
	-- 		ai{2, 1},
	-- 		1,
	-- 	}),
	-- 	t" : ",
	-- 	c(2, {
	-- 		r(nil, "key", i(nil, "and that's me")),
	-- 		{
	-- 			t"::::", r(1, "key"), t"::::"
	-- 		}
	-- 	})
	-- }),
	s("t2", {
		i(1), t" : ",
	}),
	-- s("class", fmta([[
	-- 	---@class <>
	-- 	local <> = {<>}

	-- 	<>
	-- ]], {
	-- 	rep(1),
	-- 	i(1, 'MyClass'),
	-- 	i(2),
	-- 	c(3, {
	-- 		sn(1, fmta([[
	-- 			<>function <>:new(o)
	-- 				o = o or {}
	-- 				setmetatable(o, self)
	-- 				self.__index = self
	-- 				return o
	-- 			end
	-- 		]], {
	-- 			i(1),
	-- 			rep(ai[1])
	-- 		})),
	-- 		t''
	-- 	}),
	-- })),
	parse("trig", "{\n\t$SELECT_DEDENT\n}")
}
