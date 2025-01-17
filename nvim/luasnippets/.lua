local types = require("luasnip.util.types")

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
				inode = i(insert, utils)
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

local pyinit = function(args, parent)
	-- this could also be outside the dynamicNode.
	local nodes = {t"def __init__(self"}

	-- snip.argc is controlled via c-t/c-g
	local argc = parent.argc
	-- snip.argc is not set on the first call.
	if not argc then
		parent.argc = 1
		argc = 1
	end

	-- store jump_indx separately and increase for each insertNode.
	local jump_indx = 1
	-- generate args
	for _ = 1, argc do
		vim.list_extend(nodes, {t", ", i(jump_indx, "arg"..jump_indx)})
		jump_indx = jump_indx + 1
	end
	nodes[#nodes + 1] = t{")", ""}
	-- generate assignments
	for j = 1, argc do
		vim.list_extend(nodes, {
			t"\t self.",
			i(jump_indx, "arg"..j),
			t" = ",
			-- repeat argj
			rep(j),
			t{"", ""}})
		jump_indx = jump_indx + 1
	end

	-- remove last linebreak.
	nodes[#nodes] = nil

	return sn(nil, nodes)
end

local case_node
local function get_case_node(index)
  return d(index, function()
    return sn(
      nil,
      fmta('<keyword><condition>:\n\t<body>\n\tbreak;\n\n<continuation>', {
        keyword = t({'case '}),
        condition = i(1, 'condition'),
        body = i(2, '// TODO'),
        continuation = c(3, {
            sn(
              nil,
              fmta('\ndefault:\n\t<body>\n', { body = i(1, '// TODO') }, {dedent = false})
            ),
            vim.deepcopy(case_node),
          }),
        })
    )
  end, {})
end

case_node = get_case_node(1)

local switch_case_node = fmta('<keyword><expression>) {\n<case>\n}', {
  keyword = t({'switch ', '('}),
  expression = i(1, 'expression'),
  case = isn(2, { t"\t", get_case_node(1) }, "$PARENT_INDENT\t")
})


s_add('____a',
  fmt([[https://github.com/{}/{}/archive/{}/$name-$version.tar.gz]],
	{
	  i(1, "author"),
	  i(2, "project"),
	  -- TODO: choiceNode
	  --c(3, { i(1, "$version"), i(1, "v$version") }),
	  c(3, {
	  	t"$version",
	  	t"v$version",
	  }),
	}
  )
)
s_add("trig", {i(1, "text"), dl(2, l._1, {1})})
s_add("lel", i(1, "lal"))
parse_add("lol", "a${1:$TM_CURRENT_LINE}")
s_add({trig="fn"}, {
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
}, {
	condition = function() return true end
})
s_add("pyinit", d(1, pyinit, {}, { user_args = {
	function(parent) vim.ui.input({prompt = "Number of args: "}, function(argc)
		parent.argc = math.max(argc, 1)
	end) end }}))

parse_add("bugg", "TEST: ${3:[${4:$CURRENT_MONTH_NAME $CURRENT_DATE, $CURRENT_YEAR}]} ${2:Foo}")
parse_add("buggg", "$1 asdfasdfasdff $1")

-- vim: ft=lua
