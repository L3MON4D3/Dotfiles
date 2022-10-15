local repl = require("repl")
local function nnoremapsilent(lhs, rhs)
	vim.api.nvim_set_keymap("n", lhs, rhs, {noremap = true, silent = true})
end

return {
	["/home/simon/Documents/Uni/Kurse/s6/ba/brdf-plot"] = {
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
	},
	["/home/simon/Documents/Uni/Kurse/s6/ba/brdf-plot/render"] = {
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
	},
	["/home/simon/Packages/neovim"] = {
		run = function()
			vim.o.makeprg = "cmake"
			nnoremapsilent("<space>b", ":Make --build build<Cr>")
			nnoremapsilent("<space>m", ":Make -B build<Cr>")
			vim.cmd("abbrev %% src/nvim")
			vim.cmd("abbrev %m src/nvim/main.c")
		end,
		dap = {{
			name = "nvim",
			type = "lldb",
			request = "launch",
			program = "build/bin/nvim",
			cwd = '${workspaceFolder}',
			runInTerminal = true
		}}
	},
	["/home/simon/.config/sway"] = {
		run_file = function()
			vim.bo.filetype = "swayconfig"
			vim.api.nvim_create_autocmd("BufWritePost",{
				pattern = "<buffer>",
				callback = function()
					os.execute("swaymsg reload")
				end
			})
		end
	},
}
