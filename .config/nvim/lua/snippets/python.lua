return {
	s("def", fmt([[
	def {}({}) :
		{}
	]], ins_generate())),
	s("if", fmt([[
	if {} :
		{}
	]], ins_generate())),
	s("for", fmt([[
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
}