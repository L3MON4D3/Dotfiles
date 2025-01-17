require("gruvbox").setup({
	contrast = "hard",
	transparent_mode = true,
	palette_overrides = {
		-- bright_red = "#d75151"
	},
	overrides = {
		TabLine = {
			bg = "#1d2021",
			fg = "#504945"
		},
		TabLineSel = {
			bg="#1d2021",
			fg=""
		},
		-- Since following master: have to swap fg and bg in these (Status*). Not sure
		-- where bug (? def. change in behaviour) is coming from
		Status1 = {
			fg = "#fabd2f",
			bg = "#1d2021",
			bold = true,
		},
		Status2 = {
			fg = "#fe8019",
			bg = "#1d2021",
			bold = true,
		},
		Status3 = {
			fg = "#83a598",
			bg = "#1d2021",
			bold = true,
		},

		User1 = {
			bg = "#3c3836",
			fg = "#1d2021"
		},
		StatusLine = {
			bg="#3c3836",
			fg="#1d2021"
		},
		StatusLineNC = {
			bg="#282828",
			fg="#1d2021"
		},
		NormalFloat= {
			fg="#ebdbb2",
			bg="#3c3836",
		},
		InlayHint = {
			fg="#665c54",
			bg="#3c3836",
		},

		-- don't do a palette override, only change for keywords and the like.
		GruvboxRed = { fg = "#d75151" },

		String = { italic = false },
		Operator = { italic = false },

		GruvboxRedSign = { bg = "#1d2021" },
		GruvboxYellowSign = { bg = "#1d2021" },
		GruvboxBlueSign = { bg = "#1d2021" },
		GruvboxAquaSign = { bg = "#1d2021" },

		["@string.escape"] = { bold = true },
		Function = {link = "GruvboxOrangeBold"},
		Identifier = {link = "GruvboxFg1"},
		Field = {link = "GruvboxBlue"},
		Namespace = {link = "GruvboxAquaBold"},
		["@field"] = {link = "Field"},
		["@field.lua"] = {link = "Identifier"},
		["@lsp.type.property"] = {link = "Field"},
		["@parameter"] = {link = "Identifier"},
		Method = {link = "GruvboxBlueBold"},
		["@lsp.type.method"] = {link = "Method"},
		["@lsp.type.function"] = {link = "Function"},
		["@lsp.type.namespace"] = {link = "Namespace"},
		["@lsp.type.type"] = {link = "Type"},
		["@lsp.type.class"] = {link = "Type"},
		["@lsp.type.variable"] = {link = "Identifier"},
		["@lsp.type.enumMember"] = {link = "Constant"},
		["@lsp.type.macro"] = {link = "GruvboxPurple"},
		["@lsp.type.comment"] = {link = "Comment"},

		["@lsp.mod.static"] = {link = "Field"},
		["@lsp.mod.namespace"] = {link = "Namespace"},
		["@lsp.mod.global.lua"] = {link = "Namespace"},

		["@function.cpp"] = {link = "GruvboxOrange"},

		Delimiter = {link = "GruvboxOrange"},

		["@module.latex"] = {link = "GruvboxAquaBold"},
	},
})

vim.cmd([[
	colorscheme gruvbox
	" hi! link @preproc GruvboxRed

	hi! UnderlineTransparent gui=underline

	hi! link LspReferenceText CursorLine
	hi! link LspReferenceRead CursorLine
	hi! link LspReferenceWrite CursorLine

	" for tsplayground
	hi! link NodeType GruvboxBlue

	hi! link @rule GruvboxBlue

	hi Folded guibg= cterm=none gui=none
]])
