local repl = require("repl")
local util = require("util")
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
local function vnoremapsilent_buf(buf, lhs, rhs)
	local callback = nil
	if type(rhs) == "function" then
		callback = rhs
		rhs = ""
	end
	vim.api.nvim_buf_set_keymap(buf, "v", lhs, rhs, {noremap = true, silent = true, callback = callback})
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

local function axf_debug(name, axf_full_path)
	return {
		name = name,
		my_type = name,
		type = "lldb",
		request = "launch",
		program = "build_d/mitsuba",
		args = {"-m",
				"scalar_rgb", "-t", "1",
				"-D",
				"filename=" .. axf_full_path,
				"-D",
				"width=512",
				"-D",
				"height=512",
				"-o",
				"out.exr",
				"/home/simon/Code/steinbeis/mitsuba3/scenes/matpreview_axf.xml"},
		cwd = '${workspaceFolder}',
	}
end

-- takes multiple juwels-configs, each of which consists of 2 strings:
local function hpc(cluster_name, repo, ...)
	local jconfs = {...}

	local repo_root_local = "/home/simon/Documents/Uni/Kurse/s9/hpc/ex"
	local mountpoint_local = "/home/simon/Documents/Uni/Kurse/s9/hpc/ex/" .. cluster_name
	local cluster_home = "/p/home/jusers/katz4/" .. cluster_name

	return {
		run_buf = function(args)
			local buf_fname_abs = args.file

			local buf_dir = vim.fn.fnamemodify(buf_fname_abs, ":h")

			-- remove root and "/" from filename.
			local buf_repo_local = buf_fname_abs:sub(#repo_root_local + 2)
			local buf_dir_repo_local = buf_dir:sub(#repo_root_local + 2)

			vim.api.nvim_buf_create_user_command(args.buf, "CP", function()
				-- print(("mkdir -p %s/%s"):format(mountpoint_local, buf_dir_repo_local))
				-- print(("cp %s %s/%s"):format(buf_fname_abs, mountpoint_local, buf_repo_local))

				util.process_output(("mkdir -p %s/%s"):format(mountpoint_local, buf_dir_repo_local))
				util.process_output(("cp %s %s/%s"):format(buf_fname_abs, mountpoint_local, buf_repo_local))
			end, {})

			for _, jconf in ipairs(jconfs) do
				local file_repo_relative = jconf[1]
				local conf_target = repo_root_local .. "/" .. repo .. "/" .. file_repo_relative
				local conf_build_msg = jconf[2]
				local conf_run_msg = jconf[3]

				if buf_fname_abs == conf_target then
					nnoremapsilent_buf(args.buf, "<Space>b", function()
						-- run synchronously, for now :/
						util.process_output(("cp %s %s/%s/%s"):format(conf_target, mountpoint_local, repo, file_repo_relative))
						-- if no build-msg, only update file.
						if conf_build_msg then
							repl.send(cluster_name, conf_build_msg)
						end
					end)

					if conf_run_msg then
						nnoremapsilent_buf(args.buf, "<Space>r", function()
							-- run synchronously, for now :/
							repl.send(cluster_name, conf_run_msg)
						end)
					end
				end
			end

			-- for all buffers: add mapping for toggling terminal.
			nnoremapsilent_buf(args.buf, ",j", function()
				repl.toggle(cluster_name, "below 15 split", false)
			end)
			-- also make sure we have this mapped.
			nnoremapsilent_buf(args.buf, ",i", function()
				repl.toggle("bash", "below 15 split", false)
			end)
		end,
		run_session = function()
			repl.send("bash", "systemctl --user start " .. cluster_name .. "-sshfs")
			repl.send(cluster_name, "mkdir -p " .. cluster_home .. "/" .. repo .. "/{src,bin,build,include,script,err,out}")
			repl.send(cluster_name, "cd " .. cluster_home .. "/" .. repo)
		end
	}
end

local cmake = function(opts)
	opts = opts or {}

	local cmake_args = opts.cmake_args or {}

	local cmake_opts = ""
	for _, val in ipairs(cmake_args) do
		cmake_opts = cmake_opts .. "-D" .. val .. " "
	end
	-- omit trailing " ".
	cmake_opts = cmake_opts:sub(1,-2)

	if not opts.debug then
		return repl_create("bash", {
			mappings = {
				["<Space>b"] = [[cmake --build build]],
				["<Space>m"] = ([[cmake -GNinja %s -B build]]):format(cmake_opts)
			}
		})
	end

	return conf.combine_force(repl_create("bash", {
		mappings = {
			["<Space>b"] = [[cmake --build build]],
			["<Space>m"] = ([[cmake -GNinja %s -B build; cmake -GNinja -DCMAKE_BUILD_TYPE=Debug %s -B build_d]]):format(cmake_opts, cmake_opts)
		}
	}), {
		run_buf = function(_)
			vim.api.nvim_create_user_command("DB", function()
				repl.send("bash", "cmake --build build_d")
			end, {})
		end
	})
end

local unreal = {
	run_buf = function(args)
		vim.bo[args.buf].makeprg = "ue4 build"
		nnoremapsilent_buf(args.buf, "<space>b", ":Make<Cr>")
	end
}

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
				cmake(),
				{
					run_buf = function()
						cabbrev_buf("%%", "/home/simon/Packages/neovim/src/nvim")
						cabbrev_buf("%m", "/home/simon/Packages/neovim/src/nvim/main.c")
					end,
					dap = {
						{
							name = "nvim",
							type = "lldb",
							my_type = "launch",
							request = "launch",
							program = "build/bin/nvim",
							args = {"~/b.jl"},
							cwd = '${workspaceFolder}',
							runInTerminal = true
						}
					}
				}
			),
			["/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/"] = conf.combine_force(
				cmake(), {
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
						cabbrev_buf("%b", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/src/exercise11_DeltaTracking")

						-- update this.
						cabbrev_buf("%%", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/src/exercise11_DeltaTracking")
						cabbrev_buf("%m", "/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/src/exercise11_DeltaTracking/main.cpp")
						repl_mapping(args, "bash", "<Space>r",
							"/home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/bin/exercise11_DeltaTracking -s /home/simon/Documents/Uni/Kurse/s8/cg1/ex/framework/data/exercise11_DeltaTracking/cube_cutout.xml")
					end,
				}
			),
			["/home/simon/Packages/Cemu"] = conf.combine_force(
				cmake(), {
				run_buf = function(args)
					nnoremapsilent_buf(args.buf, "<space>m", ":Make -DENABLE_VCPKG=OFF -B build<Cr>")
					cabbrev_buf("%%", "/home/simon/Packages/Cemu/src")
					cabbrev_buf("%m", "/home/simon/Packages/Cemu/src/main.cpp")
				end,
				dap = {
					{
						name = "cemu",
						type = "lldb",
						my_type = "launch",
						request = "launch",
						program = "build/bin/nvim",
						cwd = '${workspaceFolder}',
						env = 'GDK_BACKEND=x11'
					}
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
						{
							name = "cma queen",
							type = "lldb",
							my_type = "launch",
							request = "launch",
							program = "CMA",
							cwd = '${workspaceFolder}',
							runInTerminal = false,
							args = {"--graph", "graphs/queen4_4.dmx"}
						}
					}
				}
			),
			["/home/simon/Documents/Uni/Kurse/s6/ba/brdf-plot/render"] = conf.combine_force(
				cmake(), {
					run_buf = function(args)
						vim.bo[args.buf].path = vim.bo[args.buf].path .. ",data/shaders,include,shared_include,data/shaders/include"
						cabbrev_buf("@@", "data/shaders")
						cabbrev_buf("%%", "src")
						cabbrev_buf("%m", "src/main.cpp")
						nnoremapsilent_buf(args.buf, "<space>r", ":Dispatch mangohod ./build/LTSH<Cr>")
					end,
					dap = {
						{
							name = "renderdoc",
							type = "lldb",
							my_type = "renderdoc",
							request = "launch",
							program = "renderdoccmd",
							cwd = '${workspaceFolder}',
							stopOnEntry = false,
							args = {"capture", "/home/simon/Documents/Uni/Kurse/s6/ba/brdf-plot/render/build/LTSH"}
						},
						{
							name = "LTSH",
							type = "lldb",
							my_type = "launch",
							request = "launch",
							program = "/home/simon/Documents/Uni/Kurse/s6/ba/brdf-plot/render/build/LTSH",
							cwd = '${workspaceFolder}',
							stopOnEntry = false,
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
							local command = "TEST_07=false TEST_09=false make test"
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
						{
							name = "dijktest",
							type = "lldb",
							my_type = "launch",
							request = "launch",
							program = "/home/simon/Documents/Uni/Kurse/s7/co/PE_2/bin/chinese_postman",
							cwd = '${workspaceFolder}',
							runInTerminal = false,
							args = {"/home/simon/Documents/Uni/Kurse/s7/co/PE_2/graphs/grconn9882.dmx", "out"}
						}
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
			},
			["/home/simon/Code/cuora/"] = conf.combine_force(zig, {
				run_buf = function(args)
					nnoremapsilent_buf(args.buf, "<space>r", function()
						repl.send("bash", "zig build run")
						if util.process_output("pidof imv-wayland") == "" then
							repl.send("bash", "imv out.svg &")
						end
					end)
					nnoremapsilent_buf(args.buf, "<space>s", function()
						os.execute("imv out.svg &")
					end)
					cabbrev_buf("%%", "/home/simon/Code/cuora/src")
					cabbrev_buf("%m", "/home/simon/Code/cuora/src/main.zig")
				end,
				dap = {
					{
						name = "cuora",
						my_type = "launch",
						type = "lldb",
						request = "launch",
						program = "zig-out/bin/cuora",
						cwd = '${workspaceFolder}',
					}
				}
			}),
			["/home/simon/Code/steinbeis/mitsuba3/"] = conf.combine_force(
				cmake({
					debug = true,
					cmake_args = {"MI_DEFAULT_VARIANTS=\"scalar_rgb;cuda_rgb;llvm_rgb\""}
				}), {
					run_buf = function(args)
						nnoremapsilent_buf(args.buf, "<space>r", function()
							-- local steinbeis_path = "/home/simon/Code/steinbeis"
							-- repl.send("bash", ("%s/mitsuba3/build/mitsuba -m cuda_rgb -D filename=%s/axf/FSLYX9_0.axf -D width=512 -D height=512 -o out.exr %s/AxFMatPreview/matpreview/matpreview.xml"):format(steinbeis_path, steinbeis_path, steinbeis_path))
							repl.send("bash", "make run_remote")
							repl.send("bash", "gimp out.exr &")
						end)
						cabbrev_buf("%%", "/home/simon/Code/steinbeis/mitsuba3/src/bsdfs")
						cabbrev_buf("%m", "/home/simon/Code/steinbeis/mitsuba3/src/bsdfs/axf.cpp")

					end,
					dap = {
						axf_debug("sv-ward-nofs-aniso-cc-noalpha", "/home/simon/Code/steinbeis/axf/FSLYX9_0__ward_nofs_aniso_cc_noalpha.axf"),
						axf_debug("sv-ward-fs-iso-nocc-noalpha", "/home/simon/Code/steinbeis/axf/L--20H__ward_fs_iso_nocc_noalpha.axf"),
						axf_debug("sv-ward-nofs-iso-nocc-noalpha-nonormal", "/home/simon/Code/steinbeis/axf/FSBHR9_ward_nofs_iso_nocc_noalpha_nonormal_norot_lambert.axf"),
						axf_debug("sv-ward-fs-iso-nocc-noalpha-nonormal", "/home/simon/Code/steinbeis/axf/FSBJP9_ward_fs_iso_nocc_noalpha_nonormal_norot_lambert.axf"),
						axf_debug("carpaint", "/home/simon/Code/steinbeis/axf/LooB1W.axf"),
						axf_debug("sv-ward-fs-iso-nocc-noalpha-normal-norot-lambert", "/home/simon/Code/steinbeis/axf/---2YM_ward_fs_iso_nocc_noalpha_normal_norot_lambert.axf"),
						axf_debug("fsb18b", "/mnt/misc/axf/FSB18B.axf"),
						axf_debug("xq5", "/mnt/misc/axf/L--XQ5.axf"),
						axf_debug("bav79x", "/mnt/misc/axf/BAV79X.axf"),
						axf_debug("bav79x", "/mnt/misc/axf/BAV79X.axf"),
						axf_debug("bsu6qb", "/mnt/misc/axf/BSU6QB.axf"),
						axf_debug("fsb9dw", "/mnt/misc/axf/FSB9DW.axf"),
						axf_debug("gGL008", "/mnt/misc/axf/gGL008.axf"),
						axf_debug("gGL001", "/mnt/misc/axf/gGL001.axf"),
						axf_debug("gTE017", "/mnt/misc/axf/gTE017.axf"),
						{
							name = "unreal",
							type = "lldb",
							my_type = "unreal",
							request = "launch",
							program = "build_d/mitsuba",
							args = {"-m",
									"scalar_rgb", "-t", "1",
									"-D",
									"width=512",
									"-D",
									"height=512",
									"-o",
									"out.exr",
									"/home/simon/Code/steinbeis/mitsuba3/scenes/matpreview_unreal.xml"},
							cwd = '${workspaceFolder}',
						},
						{
							name = "axf_normalmap_bsu6qb",
							type = "lldb",
							my_type = "bsu6qb_normalmapped",
							request = "launch",
							program = "build_d/mitsuba",
							args = {"-m",
									"scalar_rgb", "-t", "1",
									"-D",
									"filename=" .. "/mnt/misc/axf/BSU6QB.axf",
									"-D",
									"width=512",
									"-D",
									"height=512",
									"-o",
									"out.exr",
									"/home/simon/Code/steinbeis/mitsuba3/scenes/matpreview_axf_normalmap.xml"},
							cwd = '${workspaceFolder}',
						}
					}
				}
			),
			["/home/simon/Code/steinbeis/mitsuba3/src/bsdfs/substrate/origin_files/"] = {
				run_buf = function()
					vim.diagnostic.disable()
				end
			},
			["/home/simon/Code/steinbeis/mitsuba3/src/bsdfs/substrate/"] = {
				run_buf = function()
					vim.api.nvim_create_user_command("Convert", function()
						pcall(vim.cmd, [['<,'>s/float3x3/Matrix3f/g]])
						pcall(vim.cmd, [['<,'>s/float3/Vector3f/g]])
						pcall(vim.cmd, [['<,'>s/float4/Vector4f/g]])
						pcall(vim.cmd, [['<,'>s/float2/Vector2f/g]])
						pcall(vim.cmd, [['<,'>s/float/Float/g]])
					end, {range = true})
				end
			},
			["/home/simon/Code/steinbeis/axfplayground"] = conf.combine_force(cmake(), {
				run_buf = function(args)
					nnoremapsilent_buf(args.buf, "<space>r", function()
						repl.send("bash", "/home/simon/Code/steinbeis/axfplayground/build/apg")
					end)
					cabbrev_buf("%m", "/home/simon/Code/steinbeis/axfplayground/apg.cpp")
				end,
				dap = {
					{
						name = "one-axf",
						type = "lldb",
						my_type = "launch",
						request = "launch",
						program = "build/apg",
						args = {"/mnt/misc/axf/---5AP.axf"},
						cwd = '${workspaceFolder}',
					}
				}
			}),
			["/home/simon/Code/steinbeis/Unreal-Projects/MyProject/"] = unreal,
			["/home/simon/Documents/Uni/Kurse/s9/cg2/ex/atcg_framework"] = conf.combine_force(
				cmake({debug = true}),
				{
					run_buf = function(args)

						local abspath = "/home/simon/Documents/Uni/Kurse/s9/cg2/ex/atcg_framework"
						cabbrev_buf("%m", abspath .. "/exercises/exercise02Bezier/source.cpp")
						cabbrev_buf("@@", abspath .. "/shader")

						nnoremapsilent_buf(args.buf, "<space>r", function()
							repl.send("bash", "./bin/exercise02Bezier")
						end)
					end,
					dap = {{
						name = "exercise11",
						type = "lldb",
						my_type = "launch",
						request = "launch",
						program = "bin/exercise11GPS",
						cwd = '${workspaceFolder}',
					}}
				}
			),
			["/home/simon/Documents/Uni/Kurse/s9/hpc/ex/02-running-s6sikatz"] = conf.combine_force(
				hpc(
					"juwels",
					"02-running-s6sikatz",
					-- assume we are in 02-running-s6sikatz-directory.
					{"src/hi.c", "gcc -o bin/hi src/hi.c", "./bin/hi"},
					{"src/hi_omp.c", "gcc -fopenmp -o bin/hiomp src/hi_omp.c", "./bin/hiomp"},
					{"src/hi_mpi.c", "mpicc -o bin/himpi src/hi_mpi.c", "orterun bin/himpi"},
					{"src/hi_hybrid.c", "mpicc -fopenmp -o bin/hihyb src/hi_hybrid.c", "orterun bin/hihyb"},
					{"src/hi_cuda.cu", "nvcc -o bin/hicuda src/hi_cuda.cu", "./bin/hicuda"},
					{"script/slurm_mpi.sh", nil, "sbatch script/slurm_mpi.sh"},
					{"script/slurm_hyb.sh", nil, "sbatch script/slurm_hyb.sh"},
					{"script/slurm_omp.sh", nil, "sbatch script/slurm_omp.sh"},
					{"script/slurm_cuda.sh", nil, "sbatch script/slurm_cuda.sh"}
				), {
				run_session = function()
					-- specific to this session, may not need all modules.
					repl.send("juwels", "module load GCC")
					repl.send("juwels", "module load OpenMPI")
				end
			}),
			["/home/simon/Documents/Uni/Kurse/s9/hpc/ex/04-vector-s6sikatz"] = conf.combine_force(
				hpc(
					"juwels",
					"04-vector-s6sikatz",
					{"src/sumred_4unrol.c", nil, nil},
					{"src/sumred.c", nil, nil},
					{"src/sumred_intr.c", nil, nil},
					{"src/sumred_SP_intr.c", nil, nil},
					{"src/sumred_likwid.c", nil, nil},
					{"script/run_sumred.sh", nil, "./script/run_sumred.sh"}
				), {
				run_session = function()
					-- specific to this session, may not need all modules.
					repl.send("juwels", "module load GCC")
					repl.send("juwels", "module load OpenMPI")
				end
			}),
			["/home/simon/Documents/Uni/Kurse/s9/hpc/ex/05-gpu-neural-networks-s6sikatz"] = conf.combine_force(
				hpc(
					"juwels",
					"05-gpu-neural-networks-s6sikatz",
					{"source/train_net.cpp", "cmake --build build", nil},
					{"source/net.h", "cmake --build build", nil}
				), {
				run_session = function()
					repl.send("juwels", "module load Stages/2023")
					repl.send("juwels", "module load GCC/11.3.0 OpenMPI/4.1.4 CUDA/11.7 CMake PyTorch")
				end
			}),
			["/home/simon/Documents/Uni/Kurse/s9/hpc/ex/06-memorybw-s6sikatz"] = conf.combine_force(
				hpc(
					"jureca",
					"06-memorybw-s6sikatz",
					{"src/daxpy.c", nil, nil},
					{"src/daxpy_omp.c", nil, nil},
					{"src/stream.c", nil, nil},
					{"script/run_daxpy.sh", nil, nil},
					{"script/run_stream.sh", nil, nil},
					{"script/plot_daxpy.py", nil, nil}
				), {
				run_session = function()
					repl.send("jureca", "module load GCC Intel")
				end
			}),
			["/home/simon/Documents/Uni/Kurse/s9/hpc/ex/07-pinning-s6sikatz"] = conf.combine_force(
				hpc(
					"jureca",
					"07-pinning-s6sikatz"
				), {
				run_session = function()
					repl.send("jureca", "module load GCC Intel")
				end
			}),
			["/home/simon/Documents/Uni/Kurse/s9/hpc/ex/08-network-s6sikatz"] = conf.combine_force(
				hpc(
					"jureca",
					"08-network-s6sikatz"
				), {
				run_session = function()
					repl.send("jureca", "module load GCC Intel")
				end
			}),
			["/home/simon/Documents/Uni/Kurse/s9/hpc/ex/09-openmp-s6sikatz"] = conf.combine_force(
				hpc(
					"jureca",
					"09-openmp-s6sikatz"
				), {
				run_session = function()
					repl.send("jureca", "module load GCC Intel")
				end
			}),
			["/home/simon/Documents/Uni/Kurse/s9/hpc/ex/10-mpi-s6sikatz"] = conf.combine_force(
				hpc(
					"jureca",
					"10-mpi-s6sikatz"
				), {
				run_session = function()
					repl.send("jureca", "module load Stages/2024 GCC/12.3.0 OpenMPI/4.1.5")
				end
			}),
			["/home/simon/Code/steinbeis/AxFOfflineFitting"] = {
				dap = {
					{
						name = "strata-clearcoat-ggx",
						type = "python",
						my_type = "launch-clearcoat-ggx",
						request = "launch",
						module = "scripts.fit_isotropic",
						args = {'--model_bsdf=unreal_strata_clearcoat_ggx'},
						cwd = '/home/simon/Code/steinbeis/AxFOfflineFitting',
					},
					{
						name = "strata-slab-ggx",
						type = "python",
						my_type = "launch-slab-ggx",
						request = "launch",
						module = "scripts.fit_isotropic",
						args = {'--model_bsdf=unreal_strata_slab_ggx'},
						cwd = '/home/simon/Code/steinbeis/AxFOfflineFitting',
					},
					{
						name = "ggx",
						type = "python",
						my_type = "launch-ggx",
						request = "launch",
						module = "scripts.fit_isotropic",
						args = {'--model_bsdf=ggx'},
						cwd = '/home/simon/Code/steinbeis/AxFOfflineFitting',
					},
					{
						name = "plot_isotropic",
						type = "python",
						my_type = "plot-ggx-iso",
						request = "launch",
						module = "scripts.plot_isotropic",
						args = {'--name=fit_isotropic'},
						cwd = '/home/simon/Code/steinbeis/AxFOfflineFitting',
					},
				}
			},
			["/home/simon/Documents/Uni/Kurse/s10/lab/mitsuba3"] = conf.combine_force(
				cmake({
					debug = true,
					cmake_args = {"MI_DEFAULT_VARIANTS=\"scalar_rgb;cuda_rgb;llvm_rgb\""}
				}), {
					run_buf = function(args)
						vim.api.nvim_buf_create_user_command(args.buf, "T", function()
							util.process_output("systemd-run --user -u tev tev")
						end, {})
						nnoremapsilent_buf(args.buf, "<space>r", function()
							-- local steinbeis_path = "/home/simon/Code/steinbeis"
							-- repl.send("bash", ("%s/mitsuba3/build/mitsuba -m cuda_rgb -D filename=%s/axf/FSLYX9_0.axf -D width=512 -D height=512 -o out.exr %s/AxFMatPreview/matpreview/matpreview.xml"):format(steinbeis_path, steinbeis_path, steinbeis_path))
							repl.send("bash", "make run_remote")
							repl.send("bash", "gimp out.exr &")
						end)
						cabbrev_buf("%%", "/home/simon/Code/steinbeis/mitsuba3/src/bsdfs")
						cabbrev_buf("%m", "/home/simon/Code/steinbeis/mitsuba3/src/bsdfs/axf.cpp")

					end,
				}
			),
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
				end,
				dap = {
					{
						name = "Launch",
						my_type = "launch",
						type = "lldb",
						request = "launch",
						program = function()
							return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
						end,
						cwd = '${workspaceFolder}',
						stopOnEntry = true,
					}
				}
			},
			cpp = {
				run_buf = function(args)
					nnoremapsilent_buf(args.buf, ",i", function()
						repl.toggle("bash", "below 15 split", false)
					end)
				end,
				dap = {
					{
						name = "Launch",
						type = "lldb",
						my_type = "launch",
						request = "launch",
						program = function()
							return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
						end,
						cwd = '${workspaceFolder}',
						stopOnEntry = true,
					}
				}
			},
			rust = {
				run_buf = function(args)
					nnoremapsilent_buf(args.buf, ",i", function()
						repl.toggle("bash", "below 15 split", false)
					end)
				end,
				dap = {
					{
						name = "Launch",
						type = "lldb",
						my_type = "launch",
						request = "launch",
						program = function()
							return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
						end,
						cwd = '${workspaceFolder}',
						stopOnEntry = true,
					}
				}
			},
			c = {
				run_buf = function(args)
					nnoremapsilent_buf(args.buf, ",i", function()
						repl.toggle("bash", "below 15 split", false)
					end)
				end,
				dap = {
					{
						name = "Launch",
						type = "lldb",
						my_type = "launch",
						request = "launch",
						program = function()
							return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
						end,
						cwd = '${workspaceFolder}',
						stopOnEntry = true,
					}
				}
			},
			lua = {
				dap = {
					{
						type = 'nlua',
						request = 'attach',
						my_type = "attach",
						name = "Attach to running Neovim instance",
						host = "127.0.0.1",
						port = function()
							local val = tonumber(vim.fn.input('Port: '))
							assert(val, "Please provide a port number")
							return val
						end,
					}
				}
			},
			python = {
				run_session = function()
					-- for some reason, the first one does not default to, nor known, QtAgg
					repl.send("python", "%matplotlib")
					repl.send("python", "%matplotlib")
				end,
				run_buf = function(args)
					nnoremapsilent_buf(args.buf, ",i", function()
						repl.toggle("python", "below 15 split", false)
					end)
					nnoremapsilent_buf(args.buf, "<Space>r", function()
						local filename = vim.fn.expand("%"):gsub("ipynb", "py")
						repl.send("python", ("exec(open(\"%s\").read())"):format(filename))
					end)

					vnoremapsilent_buf(args.buf, ",i", function()
						-- leave visual.
						-- this has to be done before getting visual, since the markers (<,>) are
						-- only set upon leaving Visual.
						local keys = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
						-- "x" to immediately process keys.
						vim.api.nvim_feedkeys(keys, "x", true)

						local vis = util.get_visual()
						local lines = ""
						-- regular concat omits empty lines, we don't want that.
						for _, line in ipairs(vis) do
							-- remove leading whitespace, ipython takes care of indentation.
							lines = lines .. line:gsub("^%s*", "") .. "\n"
						end
						-- remove trailing \n.
						lines = lines:sub(1,-2)
						repl.send("python", lines)
					end)
				end,
				dap = {
					{
						type = 'python',
						my_type = 'launch',
						request = 'launch',
						name = 'launch',
						program = '${file}',
						cwd = '${workspaceFolder}'
					}
				}
			},
			tex = {
				run_buf = function(run_args)
					vim.api.nvim_buf_create_user_command(run_args.buf, "IG", function(args)
						local source = args.fargs[1]
						local source_new = args.fargs[2]
						if source_new then
							os.execute("cp " .. source .. " " .. source_new)
						else
							-- in case the file should not be moved, but is already at the correct place.
							source_new = source
						end

						ls.snip_expand(ls.parser.parse_snippet("", ([[
						{
						\centering
						\includegraphics[width=${1:0.5}\textwidth]{%s}

						}
						]]):format(source_new:gsub("%.png", "")), {trim_empty=true, dedent=true}) )
					end, {complete = "file", nargs = "+"})
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
