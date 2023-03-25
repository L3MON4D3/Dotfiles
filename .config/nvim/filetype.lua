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
		PKGBUILD = "PKGBUILD"
	},
	pattern = {
		[".git/hooks/.*"] = "bash"
	}
})
