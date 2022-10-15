local mt = {
	__index = {
		dap = {},
		run = function() end
	}
}
local function new(o)
	return setmetatable(o, mt)
end

local configs = setmetatable(
	{
		["/home/simon/.config/waybar"] = new({
			run = function()
				vim.bo.filetype = "json"
			end
		})
	}, {
		__index = function(t,k)
			local l = new({})
			rawset(t,k,l)
			return l
		end,
	}
)
