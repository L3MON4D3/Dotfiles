vim.filetype.add({
	extension = {
		alpha = "alpha",
		comp = "glsl",
		frag = "glsl",
		gs = "glsl",
		plt = "gnuplot",
		sc = "cpp",
		tpp = "cpp",
		["code-snippets"] = "json",
		zon = "zig",
		ush = "c",
		usf = "c",
	},
	filename = {
		PKGBUILD = "PKGBUILD",
		["/home/simon/.config/waybar/config"] = "json"
	},
	pattern = {
		[".git/hooks/.*"] = "bash",
		["/home/simon/.config/sway/.*"] = "swayconfig",
		-- from opening current line in editor, via bash.
		["/tmp/bash%-fc%..*"] = "bash",
		['.*'] = {
			-- priority less than all other rules, but higher than defaults.
			priority = -math.huge,
			function(_, bufnr)
				local content = vim.api.nvim_buf_get_lines(bufnr, 1, 2, false)[1]
				if content == "[Unit]" then
					return "systemd"
				end
			end
		}
	},
})
