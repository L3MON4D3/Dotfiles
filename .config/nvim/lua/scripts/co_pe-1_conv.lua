local uv = vim.loop
local posix = require("posix.unistd")

local function svg_name(dot_file)
	return dot_file:gsub(".dot", ".svg")
end
local function dot_name(svg_file)
	return svg_file:gsub(".svg", ".dot")
end

return function()
	local scan_handle = uv.fs_scandir("captures")
	local function captures_iter()
		return uv.fs_scandir_next(scan_handle)
	end

	-- collect .dot-files for which no svg-file is present
	local dot_files = {}

	local svg_files = {}
	for name, _ in captures_iter do
		if name:match(".dot$") and svg_files[svg_name(name)] == nil then
			-- might be removed later!
			dot_files[name] = true
		end
		if name:match(".svg$") then
			if dot_files[dot_name(name)] then
				-- doesn't have to handled!
				dot_files[dot_name(name)] = nil
			else
				-- store svg-file, we will encounter a dot-file, which doesn't have to be handled.
				svg_files[name] = true
			end
		end
	end


	local child_pid = posix.fork()
	if child_pid == 0 then
		-- we are in child, convert .dot-files and exit.
		for fname, _ in pairs(dot_files) do
			os.execute(("dot -Tsvg %s -o %s"):format("captures/"..fname, "captures/"..svg_name(fname)))
		end

		posix._exit(0)
	end
end
