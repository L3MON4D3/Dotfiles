local function capture_insert(_, snip, _, capture_indx, pre_text, post_text)
	return sn(nil, {i(1, {(pre_text or "") .. snip.captures[capture_indx] .. (post_text or "")})})
end

s_add({trig = "for(%w+)", wordTrig = true, regTrig = true}, {
	t({"for ("}), d(1, capture_insert, {}, { user_args = {1, "int ", " = 0"}}), t({"; "}),
	f(function(_, snip) return {snip.captures[1]} end, {}), c(2, {sn(nil, {t({" != "}), i(1)}), i(nil)}), t({"; "}),
	d(3, capture_insert, {}, {user_args = {1, "++"}}), t({")", "\t"}), i(0)
})
parse_add("hguard", [[
	#ifndef $1
	#define $1

	${2:$SELECT_DEDENT}

	#endif
]])
