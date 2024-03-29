local repl = require("repl")
-- local posix = require("posix.unistd")

local conf = require("configs.config")

local function nnoremapsilent_buf(buf, lhs, rhs)
	local callback = nil
	if type(rhs) == "function" then
		callback = rhs
		rhs = ""
	end
	vim.api.nvim_buf_set_keymap(buf, "n", lhs, rhs, {noremap = true, silent = true, callback = callback})
end

local function cabbrev_buf(rhs, lhs)
	vim.cmd("cabbrev <buffer> " .. rhs .. " " .. lhs)
end

local nop = function() end

local function repl_mapping(args, name, lhs, command)
	if type(command) == "function" then
		nnoremapsilent_buf(args.buf, lhs, function()
			repl.send(name, command(args))
		end)
	else
		nnoremapsilent_buf(args.buf, lhs, function()
			repl.send(name, command)
		end)
	end
end

local function repl_create(name, spec)
	local initial_message = spec.initial_messages
	local initial_messages = spec.initial_messages or {}
	local mappings = spec.mappings or {}
	local pre = spec.pre or nop

	return {
		run_buf = function(args)
			pre(args)
			if initial_message then
				repl.send(name, initial_message)
			end
			for _, message in ipairs(initial_messages) do
				repl.send(name, message)
			end
			nnoremapsilent_buf(args.buf, ",i", function()
				repl.toggle(name, "below 15 split", false)
			end)
			for lhs, command in pairs(mappings) do
				repl_mapping(args, name, lhs, command)
			end
		end
	}
end

local cmake = repl_create("bash", {
	mappings = {
		["<Space>b"] = [[cmake --build build]],
		["<Space>m"] = [[cmake -B build]]
	}
})
local zig = {
	run_buf = function(args)
		vim.bo[args.buf].makeprg = "zig build"
		nnoremapsilent_buf(args.buf, "<space>b", ":Make<Cr>")
		nnoremapsilent_buf(args.buf, "<space>m", ":Make<Cr>")
	end
}
local make = {
	run_buf = function(args)
		vim.o.makeprg = "make"
		nnoremapsilent_buf(args.buf, "<space>b", ":Make<Cr>")
		nnoremapsilent_buf(args.buf, "<space>r", ":Make run<Cr>")
	end
}
local cargo = {
	run_buf = function(args)
		cabbrev_buf("%%", "src")
		cabbrev_buf("%m", "src/main.rs")
	end
}

local sway_reload_on_write = {
	run_buf = function(args)
		vim.api.nvim_create_autocmd("BufWritePost", {
			callback = function()
				os.execute("SWAYSOCK=/run/user/1000/sway-ipc.1000.$(pidof sway).sock swaymsg reload")
			end,
			buffer = args.buf
		})
	end
}

return {
	{
		dir = {
			["/home/simon/Documents/Uni/Kurse/s6/ba/brdf-plot"] = {
				run_session = function()
					repl.send("julia", "using Visualize")
					repl.send("julia", "using SHFit")

					vim.api.nvim_create_user_command("V", function(args)
						local fname = args.fargs

						-- make fname absolute if it is relative.
						if fname:sub(1,1) ~= "/" then
							fname = vim.fn.getcwd() .. "/" .. fname
						end

						repl.send("julia", "Visualize.main(\""..fname.."\")")
					end, {complete = "file", nargs = 1})
				end,
				run_buf = function(args)
					nnoremapsilent_buf(args.buf, "<space>sv", function()
						repl.send("julia", "Visualize.main()")
					end)
					nnoremapsilent_buf(args.buf, "<space>sf", function()
						repl.send("julia", "SHFit.main()")
					end)
					nnoremapsilent_buf(args.buf, "<space>sd", function()
						local fname = vim.fn.expand("<cWORD>")
						repl.send("julia", "Visualize.main(\"data/" .. fname .. "\")")
					end)
				end
			},
			["/home/simon/Packages/neovim"] = conf.combine_force(
				cmake, {
					run_buf = function()
						cabbrev_buf("%%", "/home/simon/Packages/neovim/src/nvim")
						cabbrev_buf("%m", "/home/simon/Packages/neovim/src/nvim/main.c")
					end,
					dap = {
						cpp = {{
							name = "nvim",
							type = "lldb",
							request = "launch",
							program = "build/bin/nvim",
							args = {"~/a.jl"},
							cwd = '${workspaceFolder}',
							runInTerminal = true
						}}
					}
				}
			),
			["/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/"] = conf.combine_force(
				cmake, {
					run_buf = function(args)
						cabbrev_buf("%c", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/CMakeLists.txt")
						cabbrev_buf("%0", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/src/exercise00_CUDAIntro")
						cabbrev_buf("%1", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/src/exercise01_HDR")
						cabbrev_buf("%2", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/src/exercise02_Raycasting")
						cabbrev_buf("%3", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/src/exercise03_WhittedRaytracing")
						cabbrev_buf("%4", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/src/exercise04_Radiosity")
						cabbrev_buf("%5", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/src/exercise05_BRDFModels")
						cabbrev_buf("%6", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/src/exercise06_Pathtracing")
						cabbrev_buf("%7", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/src/exercise07_LightsourceSampling")
						cabbrev_buf("%8", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/src/exercise08_PhotonMapping")
						cabbrev_buf("%9", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/src/exercise09_BDPT")
						cabbrev_buf("%a", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/src/exercise10_VolumetricPathtracing")

						-- update this.
						cabbrev_buf("%%", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/src/exercise10_VolumetricPathtracing")
						cabbrev_buf("%m", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/src/exercise10_VolumetricPathtracing/main.cpp")
						repl_mapping(args, "bash", "<Space>r",
							"/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/bin/exercise10_VolumetricPathtracing -s /home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/data/exercise10_VolumetricPathtracing/cornell_box_spheres_area_lights_fog.xml")
					end,
				}
			),
			["/home/simon/Packages/Cemu"] = conf.combine_force(
				cmake, {
				run_buf = function(args)
					nnoremapsilent_buf(args.buf, "<space>m", ":Make -DENABLE_VCPKG=OFF -B build<Cr>")
					cabbrev_buf("%%", "/home/simon/Packages/Cemu/src")
					cabbrev_buf("%m", "/home/simon/Packages/Cemu/src/main.cpp")
				end,
				dap = {
					cpp = {{
						name = "cemu",
						type = "lldb",
						request = "launch",
						program = "build/bin/nvim",
						cwd = '${workspaceFolder}',
						env = 'GDK_BACKEND=x11'
					}}
				}
			}),
			["/home/simon/.config/sway"] = sway_reload_on_write,
			["/home/simon/.config/waybar"] = sway_reload_on_write,
			["/home/simon/Documents/Uni/Kurse/s7/tnn/ex"] = {
				luasnip_ft_extend = {
					python = {"ipynb"}
				}
			},
			["/home/simon/Documents/Uni/Kurse/s7/co/PE_1"] = conf.combine_force(
				make, {
					run_buf = function(args)
						cabbrev_buf("%%", "/home/simon/Documents/Uni/Kurse/s7/co/PE_1/src")
						cabbrev_buf("%m", "/home/simon/Documents/Uni/Kurse/s7/co/PE_1/src/main.cpp")
						cabbrev_buf("@@", "/home/simon/Documents/Uni/Kurse/s7/co/PE_1/include")

						local convert_captures = require("scripts.co_pe-1_conv")
						vim.api.nvim_buf_create_user_command(args.buf, "C", convert_captures, {})

						vim.api.nvim_buf_create_user_command(args.buf, "Id", function()
							os.execute("imv debug.svg &")
						end, {})
						vim.api.nvim_buf_create_user_command(args.buf, "Ic", function()
							os.execute("imv captures/*.svg &")
						end, {})
					end,
					dap = {
						cpp = {{
							name = "cma queen",
							type = "lldb",
							request = "launch",
							program = "CMA",
							cwd = '${workspaceFolder}',
							runInTerminal = false,
							args = {"--graph", "graphs/queen4_4.dmx"}
						}}
					}
				}
			),
			["/home/simon/Documents/Uni/Kurse/s6/ba/brdf-plot/render"] = conf.combine_force(
				cmake, {
					run_buf = function(args)
						vim.bo[args.buf].path = vim.bo[args.buf].path .. ",data/shaders,include,shared_include,data/shaders/include"
						cabbrev_buf("@@", "data/shaders")
						cabbrev_buf("%%", "src")
						cabbrev_buf("%m", "src/main.cpp")
						nnoremapsilent_buf(args.buf, "<space>r", ":Dispatch mangohod ./build/LTSH<Cr>")
					end,
					dap = {
						cpp = {
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
				}
			),
			["/home/simon/Documents/Uni/Kurse/s6/ba/doc/thesis"] = {
				run_buf = function(args)
					vim.api.nvim_buf_create_user_command(args.buf, "B", function()
						vim.cmd("split tex/literature.bib")
					end, {})
					vim.api.nvim_buf_create_user_command(args.buf, "M", function()
						vim.cmd("split tex/macros.tex")
					end, {})
					vim.api.nvim_buf_create_user_command(args.buf, "Z", function()
						os.execute("zathura --fork thesis.pdf >/dev/null 2>&1")
					end, {})
					cabbrev_buf("%%", "/home/simon/Documents/Uni/Kurse/s6/ba/doc/thesis/tex/chapter")
					cabbrev_buf("@@", "/home/simon/Documents/Uni/Kurse/s6/ba/doc/thesis/tex/figures")
				end
			},
			["/home/simon/Code/luasnip"] = conf.combine_force(
				repl_create("bash", {
					mappings = {
						T = function()
							local command = "TEST_07=false make test"
							local file = vim.api.nvim_buf_get_name(0)
							if file:match("_spec%.lua$") then
								command = "TEST_FILE=" .. file .. " " .. command
							end
							return command
						end
					}
				}),
				{
					run_buf = function()
						cabbrev_buf("%%", "/home/simon/Code/luasnip/lua/luasnip")
						cabbrev_buf("!!", "/home/simon/Code/luasnip/tests/integration")
					end
				}
			),
			["/home/simon/Documents/Uni/Kurse/s7/co/PE_2"] = conf.combine_force(
				make, {
					run_buf = function()
						cabbrev_buf("%%", "/home/simon/Documents/Uni/Kurse/s7/co/PE_2/src")
						cabbrev_buf("%m", "/home/simon/Documents/Uni/Kurse/s7/co/PE_2/src/main.cpp")
						cabbrev_buf("@@", "/home/simon/Documents/Uni/Kurse/s7/co/PE_2/include")
					end,
					dap = {
						cpp = {{
							name = "dijktest",
							type = "lldb",
							request = "launch",
							program = "/home/simon/Documents/Uni/Kurse/s7/co/PE_2/bin/chinese_postman",
							cwd = '${workspaceFolder}',
							runInTerminal = false,
							args = {"/home/simon/Documents/Uni/Kurse/s7/co/PE_2/graphs/grconn9882.dmx", "out"}
						}}
					}
				}
			),
			["/home/simon/Documents/Uni/Kurse/s6/ba/doc/figures"] = {
				run_buf = function(args)
					vim.api.nvim_buf_create_user_command(args.buf, "Z", function()
						-- open pdf-file with s/tex/pdf on current file.
						os.execute(("zathura --fork %s.pdf >/dev/null 2>&1"):format(vim.fn.expand("%:p:r")))
					end, {})
					cabbrev_buf("%%", "/home/simon/Documents/Uni/Kurse/s6/ba/doc/figures/tex/chapter")
					cabbrev_buf("@@", "/home/simon/Documents/Uni/Kurse/s6/ba/doc/figures/tex/figures")
				end
			},
			["/home/simon/Code/termpick"] = conf.combine_force(zig, {
				run_buf = function(args)
					nnoremapsilent_buf(args.buf, "<space>r", function()
						repl.send("bash", "zig build run")
					end)
					cabbrev_buf("%%", "/home/simon/Code/termpick/src")
					cabbrev_buf("%m", "/home/simon/Code/termpick/src/main.zig")
				end
			}),
			["/home/simon/Packages/Anna Gebertz"] = {
				run_buf = function(args)
					vim.api.nvim_create_autocmd("BufWritePost", {
						callback = function()
							os.execute("qutebrowser -s new_instance_open_target tab-silent  :reload 2> /dev/null")
						end,
						buffer = args.buf
					})
				end
			}
		},
		pattern = {
			-- for PKGBUILDS of my packages.
			["^/home/simon/.packages/[^/]+/[^/]+/PKGBUILD$"] = {
				category = "file",
				run_buf = function(args)
					local repl_name = "bash." .. args.buf

					nnoremapsilent_buf(args.buf, "U", function()
						repl.send(repl_name,  "dbpush *.zst")
					end)
				end
			},
		},
		filetype = {
			PKGBUILD = {
				run_buf = function(args)
					local repl_name = "bash." .. args.buf

					-- cd into correct dir.
					repl.set_opts(repl_name, {job_opts = {cwd = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")}})

					-- want to be able to override this, can't set it in after.
					nnoremapsilent_buf(args.buf, "M", function()
						repl.send(repl_name, "rm *.zst; makepkg -f && for f in *.zst; do echo $f; tar -tvf $f; done")
					end)
					nnoremapsilent_buf(args.buf, ",i", function()
						repl.toggle(repl_name, "below 15 split", false)
					end)
				end,
				luasnip_ft_extend = {
					-- treesitter parses PKGBUILD as just bash, so we have to fix that here :/
					all = {"PKGBUILD"}
				}
			},
			julia = {
				run_buf = function(args)
					local get_visual = require("util").get_visual

					local modulename = vim.fn.expand("%:t:r")
					repl.send("julia", "using " .. modulename)

					nnoremapsilent_buf(args.buf, ",R", function()
						repl.send("julia", "using " .. modulename)
					end)

					nnoremapsilent_buf(args.buf, "<space>r", function()
						repl.send("julia", modulename..".main()")
					end)

					nnoremapsilent_buf(args.buf, ",i", function()
						repl.toggle("julia", "below 15 split", false)
					end)

					vim.keymap.set("v", ",i", function()
						-- leave visual.
						-- this has to be done before getting visual, since the markers (<,>) are
						-- only set upon leaving Visual.
						local keys = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
						-- "x" to immediately process keys.
						vim.api.nvim_feedkeys(keys, "x", true)

						local vis = get_visual()
						repl.send("julia", table.concat(vis, "\n"))
					end)
				end
			},
			zig = {
				run_buf = function(args)
					nnoremapsilent_buf(args.buf, ",i", function()
						repl.toggle("bash", "below 15 split", false)
					end)
				end
			}
		}
	},
	{
		-- pattern = {
		-- 	["^/home/simon/.packages/split/[^/]+/PKGBUILD$"] = {
		-- 		category = "file",
		-- 		run_buf = function(args)
		-- 			local repl_name = "bash." .. args.buf

		-- 			-- nnoremapsilent_buf(args.buf, ",C", function()
		-- 			-- 	-- make and install PKGBUILD
		-- 			-- 	repl.send(repl_name, "p -U $(l *cinnabar*.zst -t | head -n 1)")
		-- 			-- end)
		-- 			-- nnoremapsilent_buf(args.buf, ",T", function()
		-- 			-- 	-- make and install PKGBUILD
		-- 			-- 	repl.send(repl_name, "p -U $(l *teal*.zst -t | head -n 1)")
		-- 			-- end)
		-- 			nnoremapsilent_buf(args.buf, "R", function()
		-- 				repl.send(repl_name, "dbpush *.zst")
		-- 			end)
		-- 		end
		-- 	}
		-- }
		pattern = {
			-- only PKGBUILD immediately in subdirectory of .packages/local.
			["^/home/simon/.packages/local/[^/]+/PKGBUILD$"] = {
				category = "file",
				run_buf = function(args)
					local repl_name = "bash." .. args.buf

					nnoremapsilent_buf(args.buf, "U", function()
						-- make and install PKGBUILD
						repl.send(repl_name, "p -U $(l *.zst -t | head -n 1) --dbonly --noconfirm && dbpush *.zst")
					end)
				end
			},
		}
	}
}
