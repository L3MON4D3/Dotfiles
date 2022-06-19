local repl = require("repl")

local mt = {
	__index = {
		dap = {},
		run = function() end
	}
}
local function new(o)
	return setmetatable(o, mt)
end

return setmetatable({
	["/home/simon/Documents/Uni/Kurse/s6/ba/brdf-plot"] = new({
		run = function()
			repl.send("julia", "using Visualize")
			repl.send("julia", "using SHFit")

			vim.keymap.set("n", "<space>sv", function()
				repl.send("julia", "Visualize.main()")
			end)
			vim.keymap.set("n", "<space>sf", function()
				repl.send("julia", "SHFit.main()")
			end)

			vim.keymap.set("n", "<space>sd", function()
				local fname = vim.fn.expand("<cWORD>")
				repl.send("julia", "Visualize.main(\"data/" .. fname .. "\")")
			end)
		end
	}),
	["/home/simon/Documents/Uni/Kurse/s6/ba/brdf-plot/render"] = new({
		dap = {
			{
				name = "renderdoc",
				type = "lldb",
				request = "launch",
				program = "renderdoccmd",
				cwd = '${workspaceFolder}',
				stopOnEntry = false,
				args = {"capture", "/home/simon/Documents/Uni/Kurse/s6/ba/brdf-plot/render/build/LTSH"}
			},
			{
				name = "LTSH",
				type = "lldb",
				request = "launch",
				program = "/home/simon/Documents/Uni/Kurse/s6/ba/brdf-plot/render/build/LTSH",
				cwd = '${workspaceFolder}',
				stopOnEntry = false,
			}
		}
	}) }, {
		__index = function()
			return new({})
		end
	}
)
