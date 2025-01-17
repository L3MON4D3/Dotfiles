parse_add({trig = "if", wordTrig = true}, "if ($1)\n\t$0")
parse_add({trig = "for", wordTrig = true}, "for ($1 : $2)\n\t$0")
s_add("iferr", fmt("if ({})\n\tthrow std::runtime_error(\"failed to {}\")", {i(1), i(2)}))
parse_add("vapp", "$1.insert($1.end(), $2.begin(), $2.end())")
parse_add("allof", "$1.begin(), $1.end()")
parse_add("prag", "#pragma once")
parse_add("ns", "namespace $1 {\n\n$2\n\n}")
s_add("co", fmt([[std::cout << {} << std::endl;]], {
	c(1, {
		i(1),
		{t"glm::to_string(", i(1), t")"}
	})
}))
parse_add("hg", [[
	#ifndef $1
	#define $1

	${2:$SELECT_DEDENT}

	#endif
]])
parse_add("class", [[
	class $1 {
	public:
		$2
	private:
		$3
	};
]])
ts_px_add({
		trig = ".up",
		matchTSNode = {
			query = [[
				[
					(type_identifier)
					(template_type)
					(qualified_identifier)
				]
			@prefix ]],
			query_lang = "cpp",
			select = "longest"
		},
		reparseBuffer = "live"
	}, {
		l("std::unique_ptr<" .. l.LS_TSMATCH .. ">")
	})
ts_px_add({
		trig = ".opt",
		matchTSNode = {
			query = [[
				[
					(type_identifier)
					(template_type)
					(qualified_identifier)
				]
			@prefix ]],
			query_lang = "cpp",
			select = "longest"
		},
		reparseBuffer = "live"
	}, {
		l("std::optional<" .. l.LS_TSMATCH .. ">")
	})
