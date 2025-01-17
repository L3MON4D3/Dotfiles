parse_add({trig = "fn"}, [[
	/// $1
	fn $2($3) ${4:-> ${5:i32}} \{
		$0
	\}
]])
ts_px_add({
	trig = ".testing",
	matchTSNode = {
		query = [[(call_expression) @prefix]],
		query_lang = "rust",
	},
}, { t"hello" })
