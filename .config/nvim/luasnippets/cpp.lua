local function capture_insert(_, snip, _, capture_indx, pre_text, post_text)
	return sn(nil, {i(1, {(pre_text or "") .. snip.captures[capture_indx] .. (post_text or "")})})
end

return {
	parse({trig = "if", wordTrig = true}, "if ($1)\n\t$0"),
	parse({trig = "for", wordTrig = true}, "for ($1 : $2)\n\t$0"),
	s({trig = "for(%w+)", wordTrig = true, regTrig = true}, fmt([[
		for ({}; {}; {})
			{}
	]], {
		dl(1, "int " .. l.CAPTURE1 .. " = 0", {}),
		c(2, {sn(nil, {l(l.CAPTURE1), t({" != "}), i(1)}), i(nil)}),
		dl(3, "++" .. l.CAPTURE1, {}),
		i(0)
	})),
	s("iferr", fmt("if ({})\n\tthrow std::runtime_error(\"failed to {}\")", {i(1), i(2)})),
	parse("vapp", "$1.insert($1.end(), $2.begin(), $2.end())"),
	parse("allof", "$1.begin(), $1.end()"),
	parse("prag", "#pragma once"),
	parse("ns", "namespace $1 {\n\n$2\n\n}"),
	s("co", fmt([[std::cout << {} << std::endl;]], {
		c(1, {
			i(1),
			{t"glm::to_string(", i(1), t")"}
		})
	})),
	parse("hg", [[
		#ifndef $1
		#define $1

		${2:$SELECT_DEDENT}

		#endif
	]])
}
