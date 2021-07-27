local ls = require'luasnip'
local s = ls.s
local sn = ls.sn
local t = ls.t
local i = ls.i
local f = ls.f
local c = ls.c
local d = ls.d
local l = require'luasnip.extras'.l
local r = require'luasnip.util.functions'.rep
local p = require("luasnip.util.functions").partial

require'luasnip.config'.set_config({
	history = true,
	updateevents = 'TextChangedI'
})

local function copy(args)
	return args[1]
end

local function char_count_same(c1, c2)
	local line = vim.api.nvim_get_current_line()
	local _, ct1 = string.gsub(line, c1, '')
	local _, ct2 = string.gsub(line, c2, '')
	return ct1 == ct2
end

local function even_count(c)
	local line = vim.api.nvim_get_current_line()
	local _, ct = string.gsub(line, c, '')
	return ct % 2 == 0
end

local function neg(fn, ...)
	return not fn(...)
end

local function jdocsnip(args, old_state)
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

local rec_ls
rec_ls = function()
	return sn(nil, {
		c(1, {
			t({""}),
			sn(nil, {t({"", "\t\\item "}), i(1), d(2, rec_ls, {})}),
		}),
	});
end

local function capture_insert(args, _, capture_indx, pre_text, post_text)
	print(capture_indx)
	return sn(nil, {i(1, {(pre_text or "") .. args[1].captures[capture_indx] .. (post_text or "")})})
end

local function copy_insert(args, _, indx, pre_text, post_text)
	return sn(nil, {i(1, {(pre_text or "") .. args[indx][1] .. (post_text or "")})})
end

ls.snippets = {
	all = {
		s({trig="(", wordTrig=false}, { t({"("}), i(1), t({")"}), i(0) }, neg, char_count_same, '%(', '%)'),
		s({trig="{", wordTrig=false}, { t({"{"}), i(1), t({"}"}), i(0) }, neg, char_count_same, '%{', '%}'),
		s({trig="[", wordTrig=false}, { t({"["}), i(1), t({"]"}), i(0) }, neg, char_count_same, '%[', '%]'),
		s({trig="<", wordTrig=false}, { t({"<"}), i(1), t({">"}), i(0) }, neg, char_count_same, '<', '>'),
		s({trig="'", wordTrig=false}, { t({"'"}), i(1), t({"'"}), i(0) }, neg, even_count, '\''),
		s({trig="\"", wordTrig=false}, { t({"\""}), i(1), t({"\""}), i(0) }, neg, even_count, '"'),
		s({trig="`", wordTrig=false}, { t({"`"}), i(1), t({"`"}), i(0) }, neg, even_count, '`'),
		s({trig="{,", wordTrig=false}, { t({"{","\t"}), i(1), t({"", "}"}) }),
		s({trig = "trig"}, {
			i(1, "lele"), i(2, "lolo"),
			l(l._1..l._2, {1,2})
		})
	},
	java = {
		s({trig="fn"}, {
			d(6, jdocsnip, {2, 4, 5}), t({"", ""}),
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
		})
	},
	rust = {
		ls.parser.parse_snippet({trig = "fn"}, "/// $1\nfn $2($3) ${4:-> $5 }\\{\n\t$0\n\\}")
	},
	help = {
		s({trig="con", wordTrig=true}, {
			i(1),
			f(function(args) return {" "..string.rep(".", 80-(#args[1][1]+#args[2][1]+2+2)).." "} end, {1, 2}),
			t({"|"}),
			i(2),
			t({"|"}),
			i(0)
		}),
		s({trig="*", wordTrig=true}, {
			t({"*"}),
			i(1),
			t({"*"}),
			i(0)
		}, neg, even_count, '%*'),
	},
	lua = {
		s({trig="if", wordTrig=true}, {
			t({"if "}),
			i(1),
			t({" then", "\t"}),
			i(0),
			t({"", "end"})
		}),
		s({trig="ee", wordTrig=true}, {
			t({"else", "\t"}),
			i(0),
		})
	},
	tex = {
		ls.parser.parse_snippet({trig = ";"}, "\\$$1\\$$0"),
		s({trig = "(s*)sec", wordTrig = true, regTrig = true}, {
			f(function(args) return {"\\"..string.rep("sub", string.len(args[1].captures[1]))} end, {}),
			t({"section{"}), i(1), t({"}", ""}), i(0)
		}),
		ls.parser.parse_snippet({trig = "beg", wordTrig = true}, "\\begin{$1}\n\t$2\n\\end{$1}"),
		ls.parser.parse_snippet({trig = "beq", wordTrig = true}, "\\begin{equation*}\n\t$1\n\\end{equation*}"),
		ls.parser.parse_snippet({trig = "bal", wordTrig = true}, "\\begin{aligned}\n\t$1\n\\end{aligned}"),
		ls.parser.parse_snippet({trig = "ab", wordTrig = true}, "\\langle $1 \\rangle"),
		ls.parser.parse_snippet({trig = "lra", wordTrig = true}, "\\leftrightarrow"),
		ls.parser.parse_snippet({trig = "Lra", wordTrig = true}, "\\Leftrightarrow"),
		ls.parser.parse_snippet({trig = "fr", wordTrig = true}, "\\frac{$1}{$2}"),
		ls.parser.parse_snippet({trig = "tr", wordTrig = true}, "\\item $1"),
		ls.parser.parse_snippet({trig = "abs", wordTrig = true}, "\\|$1\\|"),
		s({trig = "ls"}, {
			t({"\\begin{itemize}",
			"\t\\item "}), i(1), d(2, rec_ls, {}),
			t({"", "\\end{itemize}"}), i(0)
		})
	},
	cpp = {
		ls.parser.parse_snippet({trig = "if", wordTrig = true}, "if ($1)\n\t$2\n$0"),
		ls.parser.parse_snippet({trig = "for", wordTrig = true}, "for ($1 : $2)\n\t$3\n$0"),
		s({trig = "for(%w+)", wordTrig = true, regTrig = true}, {
			t({"for ("}), d(1, capture_insert, {}, 1, "int ", " = 0"), t({"; "}),
			f(function(args) return {args[1].captures[1]} end, {}), c(2, {sn(nil, {t({" != "}), i(1)}), i(nil)}), t({"; "}),
			d(3, capture_insert, {}, 1, "++"), t({")", "\t"}), i(4), t({"", ""}), i(0)
		})
	}
}
