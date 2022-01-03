return {
	s("for", fmt([[
		for {} in {}; do
			{}
		done
	]], ins_generate()))
}
