local p = require("dbus_proxy")
local vkinfo = require("vkinfo")

local function find_zathura_dbus()
	local fd = io.popen("pidof zathura")
	-- skip linebreak.
	local pidofstring = fd:read("*all"):sub(1, -2)

	if #pidofstring == 0 then
		return nil
	end
	for _, pidstr in ipairs(vim.split(pidofstring, " ")) do
		local proxy = p.Proxy:new({
			bus = p.Bus.SESSION,
			name = "org.pwmt.zathura.PID-" .. pidstr,
			interface = "org.pwmt.zathura",
			path = "/org/pwmt/zathura"
		})
		if proxy.filename:match("vkspec.pdf$") then
			return proxy
		end
	end

	return nil
end

local function to_search_name(word)
	-- does not begin with any of vk, Vk
	if word:sub(1,2):lower() ~= "vk" then
		word = "Vk"..word
	end
	if vkinfo.structnames[word] then
		return "typedef struct " .. word
	end
	if vkinfo.handlenames[word] then
		return "HANDLE(" .. word .. ")"
	end
	if vkinfo.enumnames[word] then
		return "typedef enum " .. word

	end
	if vkinfo.functions[word] then
		return word .. "(\n"
	end

	-- not found -> just search for word.
	return word
end

local dbus
vim.keymap.set("n", "<C-S-K>", function()
	local word = to_search_name(vim.fn.expand("<cword>"))
	if not word then
		vim.notify("Invalid query: " .. word)
		return
	end
	-- dbus has to be initialized.
	if not dbus then
		dbus = find_zathura_dbus()
		-- vkspec might not have been opened yet!
		if not dbus then
			vim.defer_fn(function()
				io.popen("bash -c 'zathura --fork ~/Documents/vkspec.pdf -f \"" .. word .. "\" > /dev/null 2>/dev/null'")
			end, 0)
			return
		end
	end
	dbus:Search(word)
	vim.notify("Couldn't find vkspec in any zathura session.")
end)
