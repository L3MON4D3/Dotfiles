parse_add("imp", [[const $1 = @import("$2")$0;]])
parse_add("if", [[
	if ($1) {
		$2
	}
]])
parse_add("for", [[
	for ($1) |$2| {
		$3
	}
]])
parse_add({trig = "for(%w+)", wordTrig = true, regTrig = true}, [[
	for (0..$1) |${LS_CAPTURE_1}| {
		$0
	}
]])

ts_px_add({
		trig = ".map",
		matchTSNode = {
			query = [[ (identifier) @prefix ]],
			query_lang = "zig",
			select = "longest"
		},
		reparseBuffer = "live"
	}, fmt([[
			for {} {{
				{}
			}}
		]], {
			c(1, {
				parse(nil, "($LS_TSMATCH) |$1|"),
				parse(nil, "($LS_TSMATCH, ${1:0..}) |$2, ${3:i}|"),
			}),
			i(0)
		}))
ts_px_add({
		trig = ".c",
		matchTSNode = {
			query = [[ (call_expression) @prefix ]],
			query_lang = "zig",
			select = "longest"
		},
		reparseBuffer = "live"
	}, parse(nil, "$LS_TSMATCH catch ${1:unreachable}"))
ts_px_add({
		trig = ".cu",
		matchTSNode = {
			query = [[ (call_expression) @prefix ]],
			query_lang = "zig",
			select = "longest"
		},
		reparseBuffer = "live"
	}, parse(nil, "$LS_TSMATCH catch unreachable"))
ts_px_add({
		trig = ".t",
		matchTSNode = {
			query = [[ (call_expression) @prefix ]],
			query_lang = "zig",
			select = "longest"
		},
		reparseBuffer = "live"
	}, parse(nil, "try $LS_TSMATCH"))

ts_px_add({
		trig = ".f32",
		matchTSNode = {
			query = [[ (identifier) @prefix ]],
			query_lang = "zig",
			select = "shortest"
		},
		reparseBuffer = "live"
	}, parse(nil, "@as(f32, @floatFromInt($LS_TSMATCH))"))

s_add("struct", {
	c(1, {
		t"pub ",
		t""
	}),
	c(2, {
		fmt([[
			const {} = struct {{
				const Self = @This();
				{}
			}};
		]], {r(1, "name", i(1)), r(2, "body", i(1)) }),
		fmt([[
			fn {}({}) type {{
				return struct {{
					const Self = @This();
					{}
				}};
			}}
		]], {r(1, "name", i(1)), i(2), r(3, "body", i(1)) })
	})
})

s_add("while", fmt([[
	while ({}) {}{{
		{}
	}}
]], {i(1), c(2, {t"", {t"|",i(1),t"| "} }), i(3) }))
