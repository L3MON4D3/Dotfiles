vim.filetype.add({
	extension = {
		alpha = "alpha",
		comp = "glsl",
		frag = "glsl",
		plt = "gnuplot",
		sc = "cpp",
		tpp = "cpp"
	},
	filename = {
		PKGBUILD = "PKGBUILD",
		["/home/simon/.config/waybar/config"] = "json"
	},
	pattern = {
		[".git/hooks/.*"] = "bash",
		["/home/simon/.config/sway/.*"] = "swayconfig",
		-- from opening current line in editor, via bash.
		["/tmp/bash%-fc%..*"] = "bash"
	},
})
