s_add("for", fmt([[
	for {} in {}; do
		{}
	done
]], ins_generate()))
s_add("if", fmt([[
	if [ {} ]; then
		{}
	fi
]], ins_generate()))
