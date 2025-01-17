require('lualine').setup {
	options = {
		icons_enabled = false,
		theme = 'gruvbox',
		always_divide_middle = true,
		globalstatus = false,
	},
	sections = {
		lualine_a = {'filename'},
		lualine_z = {'location'}
	},
	inactive_sections = {
		lualine_a = {"filename"},
		lualine_b = {},
		lualine_c = {'filename'},
		lualine_x = {'location'},
		lualine_y = {},
		lualine_z = {}
	},
	tabline = {},
	extensions = {}
}
