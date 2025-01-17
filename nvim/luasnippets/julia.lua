s_add("fn", fmt([[
	function{}({})
		{}
	end
]], ins_generate()))
s_add("f", fmt([[{}({}) = {}]], ins_generate()))
parse_add("if", "if $1\n\t$2\nend")
s_add("for", fmt([[
	for {}
		{}
	end
]], ins_generate()))
parse_add("d", "display(${1:$LS_SELECT_DEDENT})")
parse_add_auto("theta", "θ")
parse_add_auto("phi", "φ")
-- parse_add_auto("alpha", "α")
-- parse_add_auto("pi", "π")
-- parse_add_auto("eta", "η")
parse_add("xor", "⊻")
parse_add("struct", [[
	struct $1
		$2
	end
]])

-- parse_add("p", "println(\"$1\", $2)")
s_add("p", fmt([[println("{}", {})]], {i(1, "", {key="i1"}), dl(2, l._1:gsub(" $", ""), {k("i1")})}))

parse_add("lus", [[
	include("$1.jl")
	using .$1
]])
