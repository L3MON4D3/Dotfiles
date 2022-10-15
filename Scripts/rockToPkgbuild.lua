#!/usr/bin/env lua

local rockspec_name = assert(arg[1])

local function log(level, fmt, ...)
	io.stderr:write(level .. "\t" .. string.format(fmt, ...) .. "\n")
end

local function append(tbl, ...)
	for _, v in ipairs {...} do
		tbl[#tbl+1] = v
	end
	return tbl
end

local function shell_single_quote(str)
	str = "'" .. str:gsub("'", "'\\''") .. "'"
	return str
end

local function shell_quote(str)
	if str:match("[^%w%_%:%/%@%^%.%-]") then
		str = shell_single_quote(str)
	end
	return str
end
local q = shell_quote

local function load_rockspec(path)
	local env = {}
	local rockspec = assert(loadfile(path, "t", env))
	rockspec()
	return env
end

local config = load_rockspec(rockspec_name)
local PKGBUILD = {}
local function add_var(name, value)
	if type(value) == "string" then
		append(PKGBUILD, name .. "=" .. shell_quote(value))
	elseif type(value) == "table" then
		if next(value) == nil then
			-- Do nothing
		elseif value[1] then -- Array
			local t = {}
			for i,v in ipairs(value) do
				t[i] = shell_quote(v)
			end
			append(PKGBUILD, name .. "=(" .. table.concat(t, " ") .. ")")
		else
			error("Unable to serialise table" .. name)
		end
	else
		log("warn", name .. " is not a string: ", value)
	end
end
add_var("pkgname", "lua51-"..config.package)
add_var("pkgver", config.version:gsub("%-","_"))
add_var("pkgrel", "0")
if config.description.summary then
	add_var("pkgdesc", config.description.summary)
end
add_var("arch", {"any"})
add_var("url", config.description.homepage)
add_var("license", {(config.description.license:gsub("^MIT/X11$","MIT"))})
append(PKGBUILD, "depends=('luarocks' 'lua51')")

local url = config.source.url
append(PKGBUILD, ("source=(%s %s)"):format(rockspec_name, url:gsub("git://", "git+https://")))

local md5 = config.source.md5
--[[if md5 == nil then
	log("info", "No md5 sum found in rockspec downloading source to calculate it")
	--md5 = io.popen("curl -Ls " .. shell_quote(url) .." | md5sum -b"):read"*l":match"%x+"
	md5 = "SKIP"
end]]
log("debug", "Calculating md5 for rockspec")
local rockspec_md5 = io.popen("md5sum " .. shell_quote(rockspec_name)):read"*l":match"%x+"
add_var("md5sums", {rockspec_md5, md5 or "SKIP"})

local source_dir = config.source.dir or config.source.url:match("([^/.]+)%.?[^/]*$")
table.insert(PKGBUILD, [[
build() {
	cd ]] .. q(source_dir) .. [[;
	luarocks --lua-version 5.1 make --pack-binary-rock --deps-mode=none "${srcdir}"/]] .. q(rockspec_name) .. [[;
}
package() {
	cd ]] .. q(source_dir) .. [[;
	luarocks --lua-version 5.1 --tree="${pkgdir}/usr" install --deps-mode=none --no-manifest ]] .. q(config.package.."-"..config.version) .. [[.*.rock
}]])
print(table.concat(PKGBUILD, "\n"))
