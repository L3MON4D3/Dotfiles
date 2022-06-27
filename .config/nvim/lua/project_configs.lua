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

			function quick_visualize(fname)
				if fname:sub(1,1) ~= "/" then
					fname = vim.fn.getcwd() .. "/" .. fname
				end
				repl.send("julia", "Visualize.main(\""..fname.."\")")
			end

			vim.cmd[[command! -nargs=1 -complete=file V :lua quick_visualize(<f-args>)]]
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
