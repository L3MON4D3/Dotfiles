require("plugins.luasnip.helpers").setup_snip_env()

return  {
		ls.parser.parse_snippet({trig = "fn"}, [[
/// $1
fn $2($3) ${4:-> ${5:i32}} \{
	$0
\}
]])
}
