local repl = require("repl")
-- local posix = require("posix.unistd")

local conf = require("configs.config")

local function nnoremapsilent(lhs, rhs)
	local callback = nil
	if type(rhs == "function") then
		callback = rhs
		rhs = ""
	end
	vim.api.nvim_set_keymap("n", lhs, rhs, {noremap = true, silent = true, callback = callback})
end

local cmake = {
	run_session = function()
		vim.o.makeprg = "cmake"
		nnoremapsilent("<space>b", ":Make --build build<Cr>")
		nnoremapsilent("<space>m", ":Make -B build<Cr>")
	end
}
local zig = {
	run_session = function()
		vim.o.makeprg = "zig build"
		nnoremapsilent("<space>b", ":Make<Cr>")
		nnoremapsilent("<space>m", ":Make<Cr>")
	end
}
local make = {
	run_session = function()
		vim.o.makeprg = "make"
		nnoremapsilent("<space>b", ":Make<Cr>")
		nnoremapsilent("<space>r", ":Make run<Cr>")
	end
}


return {
	["/home/simon/Documents/Uni/Kurse/s6/ba/brdf-plot"] = {
		run_session = function()
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

			function Quick_visualize(fname)
				if fname:sub(1,1) ~= "/" then
					fname = vim.fn.getcwd() .. "/" .. fname
				end
				repl.send("julia", "Visualize.main(\""..fname.."\")")
			end

			vim.cmd[[command! -nargs=1 -complete=file V :lua Quick_visualize(<f-args>)]]
		end
	},
	["/home/simon/Packages/neovim"] = conf.combine_force(
		cmake, {
			run_session = function()
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
		}
	),
	["/home/simon/Packages/Cemu"] = conf.combine_force(
		cmake, {
		run_session = function()
			nnoremapsilent("<space>m", ":Make -DENABLE_VCPKG=OFF -B build<Cr>")
			vim.cmd("abbrev %% src")
			vim.cmd("abbrev %m src/main.cpp")
		end,
		dap = {{
			name = "cemu",
			type = "lldb",
			request = "launch",
			program = "build/bin/nvim",
			cwd = '${workspaceFolder}',
			env = 'GDK_BACKEND=x11'
		}}
	}),
	["/home/simon/.config/sway"] = {
		run_buf = function()
			vim.bo.filetype = "swayconfig"
			vim.api.nvim_create_autocmd("BufWritePost",{
				pattern = "<buffer>",
				callback = function()
					os.execute("SWAYSOCK=/run/user/1000/sway-ipc.1000.$(pidof sway).sock swaymsg reload")
				end
			})
		end
	},
	["/home/simon/Documents/Uni/Kurse/s7/tnn/ex"] = {
		luasnip_ft_extend = {
			python = {"ipynb"}
		}
	},
	["/home/simon/Documents/Uni/Kurse/s7/co/PE_1"] = conf.combine_force(
		make, {
			run_session = function()
				vim.cmd("abbrev %% src")
				vim.cmd("abbrev %m src/main.cpp")
				vim.cmd("abbrev @@ include")

				local convert_captures = require("scripts.co_pe-1_conv")
				vim.api.nvim_create_user_command("C", convert_captures, {})

				vim.api.nvim_create_user_command("Id", function()
					os.execute("imv debug.svg &")
				end, {})
				vim.api.nvim_create_user_command("Ic", function()
					os.execute("imv captures/*.svg &")
				end, {})
			end,
			dap = {{
				name = "cma queen",
				type = "lldb",
				request = "launch",
				program = "CMA",
				cwd = '${workspaceFolder}',
				runInTerminal = false,
				args = {"--graph", "graphs/queen4_4.dmx"}
			}}
		}
	),
	["/home/simon/Documents/Uni/Kurse/s6/ba/brdf-plot/render"] = conf.combine_force(
		cmake, {
			run_session = function()
				vim.cmd[[
					set path+=data/shaders,include,shared_include,data/shaders/include
					nnoremap <silent> <space>r :Dispatch mangohud ./build/LTSH<Cr>

					cabbr <expr> @@ "data/shaders"
					cabbr <expr> %% "src"
					cabbr <expr> %m "src/main.cpp"
				]]
			end,
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
		}
	),
	["/home/simon/Documents/Uni/Kurse/s6/ba/doc/thesis"] = {
		run_session = function()
			vim.api.nvim_create_user_command("B", function()
				vim.cmd("split tex/literature.bib")
			end, {})
			vim.api.nvim_create_user_command("M", function()
				vim.cmd("split tex/macros.tex")
			end, {})
			vim.api.nvim_create_user_command("Z", function()
				os.execute("zathura --fork thesis.pdf >/dev/null 2>&1")
			end, {})
			vim.cmd[[
				cabbr <expr> %% "tex/chapter"
				cabbr <expr> @@ "tex/figures"
			]]
		end
	},
	["/home/simon/Code/Lua/luasnip"] = {
		run_session = function()
			print("here")
			vim.cmd[[
				cabbr %% lua/luasnip
				cabbr !! tests/integration
			]]
		end
	},
	["/home/simon/Documents/Uni/Kurse/s7/co/PE_2"] = conf.combine_force(
		make, {
			run_session = function()
				vim.cmd("abbrev %% src")
				vim.cmd("abbrev %m src/main.cpp")
				vim.cmd("abbrev @@ include")

				-- local convert_captures = require("scripts.co_pe-1_conv")
				-- vim.api.nvim_create_user_command("C", convert_captures, {})

				-- vim.api.nvim_create_user_command("Id", function()
				-- 	os.execute("imv debug.svg &")
				-- end, {})
				-- vim.api.nvim_create_user_command("Ic", function()
				-- 	os.execute("imv captures/*.svg &")
				-- end, {})
			end,
			dap = {{
				name = "dijktest",
				type = "lldb",
				request = "launch",
				program = "./bin/postman",
				cwd = '${workspaceFolder}',
				runInTerminal = false,
				args = {"graphs/grconn9882.dmx", "out"}
			}}
		}
	),
	["/home/simon/Documents/Uni/Kurse/s6/ba/doc/figures"] = {
		run_session = function()
			vim.api.nvim_create_user_command("Z", function()
				-- open pdf-file with s/tex/pdf on current file.
				os.execute(("zathura --fork %s.pdf >/dev/null 2>&1"):format(vim.fn.expand("%:p:r")))
			end, {})
			vim.cmd[[
				cabbr <expr> %% "tex/chapter"
				cabbr <expr> @@ "tex/figures"
			]]
		end
	},
	["/home/simon/Code/termpick"] = conf.combine_force(zig, {
		run_session = function()
			nnoremapsilent("<space>r", function()
				repl.send("bash", "zig build run")
			end)
			vim.cmd("abbrev %% src")
			vim.cmd("abbrev %m src/main.zig")
		end
	}),
	["/home/simon/.config/waybar/config"] = {
		run_buf = function()
			vim.bo.filetype = "json"
		end
	},
}
