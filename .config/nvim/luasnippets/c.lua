local function capture_insert(_, snip, _, capture_indx, pre_text, post_text)
	return sn(nil, {i(1, {(pre_text or "") .. snip.captures[capture_indx] .. (post_text or "")})})
end

return {
	ls.parser.parse_snippet({trig = "if", wordTrig = true}, "if ($1)\n\t$0"),
	ls.parser.parse_snippet({trig = "for", wordTrig = true}, "for ($1 : $2)\n\t$0"),
	s({trig = "for(%w+)", wordTrig = true, regTrig = true}, {
		t({"for ("}), d(1, capture_insert, {}, { user_args = {1, "int ", " = 0"}}), t({"; "}),
		f(function(args, snip) return {snip.captures[1]} end, {}), c(2, {sn(nil, {t({" != "}), i(1)}), i(nil)}), t({"; "}),
		d(3, capture_insert, {}, {user_args = {1, "++"}}), t({")", "\t"}), i(0)
	}),
}
