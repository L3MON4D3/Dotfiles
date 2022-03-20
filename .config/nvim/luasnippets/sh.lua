return {
	s("for", fmt([[
		for {} in {}; do
			{}
		done
	]], ins_generate())),
	s("if", fmt([[
		if [ {} ]; then
			{}
		fi
	]], ins_generate()))
}
