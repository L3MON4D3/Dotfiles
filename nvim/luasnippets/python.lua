s_add("def", fmt([[
def {}({}) :
	{}
]], ins_generate()))

s_add("if", fmt([[
if {} :
	{}
]], ins_generate()))
s_add("for", fmt([[
for {} :
	{}
]], ins_generate({
	[1] = c(1, {
		{ i(1, "i"), t" in ", c(2, {
			{i(1)},
			{i(1), t"range(", c(2, {
				{r(1, "high", i(1))},
				{r(1, "low", i(1)), t", ", r(2, "high", i(1))},
				{r(1, "high", i(1)), t", ", r(2, "low", i(1)), t", ", i(3, "-1")},
			}), t")"}
		}) },
		{i(1, "key"), t", ", i(2, "val"), t" in enumerate(", i(3), t")"},
		{i(1, "key"), t", ", i(2, "val"), t" in enumerate(", i(3), t")"}
	})
})))
parse_add("class", [[
	class $1 :
		
]])
parse_add("init", [[
	def __init__(self) :
		$1
]])
parse_add("meth", [[
	def $1(self$2) :
		$3
]])

px_add({trig=".p", match_pattern = "^%s+(.*)"}, parse(nil, [[print($POSTFIX_MATCH)]]))

local function import(shorthand, importname)
	parse_add(shorthand, ("import %s as %s"):format(importname, shorthand))
end

import("pd", "pandas")
import("px", "plotly.express")
import("np", "numpy")
import("sns", "seaborn")
import("plt", "matplotlib.pyplot")
import("sk", "sklearn")
