parse_add_auto("v3", "Vector3f")
parse_add_auto("unus", "UNUSED($1)")
parse_add_auto("ttf", "template<typename Float>")
parse_add_auto("tts", "template<typename Float, typename Spectrum>")
parse_add("mv", "MI_VARIANT")
parse_add({trig=".fs", wordTrig=false}, "<Float, Spectrum>")
parse_add("isnan", [[dr::any_or<false>(dr::isnan($1))]])
parse_add("ifj", [[
if constexpr (${1|!,|}dr::is_jit_v<Float>)
	$2
]])
parse_add("ifp", [[
if constexpr (${1|!,|}is_polarized_v<Spectrum>)
	$2
]])
parse_add("drif", [[
if (dr::any_or<false>($1))
	$2
]])
ts_px_add({
		trig = ".a",
		matchTSNode = {
			query = [[
				[
					(call_expression)
					(identifier)
				]
			@prefix ]],
			query_lang = "cpp",
			select = "longest"
		},
		reparseBuffer = "live"
	}, {
		l("dr::abs(" .. l.LS_TSMATCH .. ")")
	})
