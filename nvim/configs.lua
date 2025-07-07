local repl = require("repl")
local util = require("util")
local mc = require("matchconfig")
local matchers = mc.matchers
local actions = mc.actions

local mft = matchers.filetype
local mpattern = matchers.pattern
local mfile = matchers.file
local mdir = matchers.dir
local mgeneric = matchers.generic
local project_matchers = require("matchconfig.extras.matchers.projects")

local c = mc.config

local nnoremapsilent_buf = actions.nnoremapsilent_buf
local vnoremapsilent_buf = actions.vnoremapsilent_buf
local cabbrev_buf = actions.cabbrev_buf
local usercommand_buf = actions.usercommand_buf
local autocmd_buf = actions.autocmd_buf
local undo_append = actions.undo_append

local merge = require("matchconfig.options.util.merge")

local nop3 = function(_,_,_) end

local repl_primary = require("my_mc.options.repl").primary
local repl_secondary = require("my_mc.options.repl").secondary
local direncode = require("my_mc.options.repl").direncode
local dirdecode = require("my_mc.options.repl").dirdecode

local eval = mc.eval

-- bash in some directory.
repl.set_term_generator("bash_dir", function(term_id)
	local match = term_id:match("bash%.dir%:([^%.]+)")
	if match then
		return {
			cmd = {"bash"},
			job_opts = {
				cwd = dirdecode(match)
			}
		}
	end
end)

-- takes multiple juwels-configs, each of which consists of 2 strings:
local cmake_attach = function(repl_id, opts)
	opts = opts or {}

	local cmake_args = opts.cmake_args or {}

	local cmake_opts = ""
	for _, val in ipairs(cmake_args) do
		cmake_opts = cmake_opts .. "-D" .. val .. " "
	end
	-- omit trailing " ".
	cmake_opts = cmake_opts:sub(1,-2)

	if not opts.debug then
		return c{
			repl = {
				run = {
					id = repl_id,
					mappings = {
						["<Space>b"] = [[cmake --build build]],
						["<Space>m"] = ([[cmake -GNinja %s -B build]]):format(cmake_opts)
					},
				},
				set_type = {id = repl_id, type = repl_secondary}
			}
		}
	end

	return c{
		repl = {
			run = {
				id = repl_id,
				mappings = {
					["<Space>b"] = [[cmake --build build]],
					["<Space>m"] = ([[cmake -GNinja %s -B build; cmake -GNinja -DCMAKE_BUILD_TYPE=Debug %s -B build_d]]):format(cmake_opts, cmake_opts)
				},
				once = function(_, effective_repl_id)
					usercommand_buf("DB", function()
						repl.send(effective_repl_id, "cmake --build build_d")
					end, {})
				end
			},
			set_type = {id = repl_id, type = repl_secondary}
		}
	}
end

local lsp_generic = c{
	run_buf = function()
		nnoremapsilent_buf('K', vim.lsp.buf.hover)
		nnoremapsilent_buf('gd', vim.lsp.buf.declaration)
		nnoremapsilent_buf('gD', vim.lsp.buf.definition)
		nnoremapsilent_buf('gi', vim.lsp.buf.implementation)
		nnoremapsilent_buf('gr', vim.lsp.buf.references)
		nnoremapsilent_buf('<space>D', vim.lsp.buf.type_definition)
		nnoremapsilent_buf('<space>d', vim.diagnostic.open_float)
		nnoremapsilent_buf('<space>n', vim.lsp.buf.rename)
		nnoremapsilent_buf('<space>ca', vim.lsp.buf.code_action)
		nnoremapsilent_buf('<space>ci', vim.lsp.buf.incoming_calls)
		nnoremapsilent_buf('<space>co', vim.lsp.buf.outgoing_calls)

		nnoremapsilent_buf("<space>v", function()
			local conf = vim.diagnostic.config()
			vim.diagnostic.config({
				virtual_text = not conf.virtual_text,
				underline = not conf.underline
			})
		end)
	end
}

---
--- Filetypes
---

--
-- PKGBUILD
--
mc.register(mft"PKGBUILD", c{
	luasnip_ft_extend = {
		-- treesitter parses PKGBUILD as just bash, so we have to fix that here :/
		all = {"PKGBUILD"}
	}
})

mc.register(project_matchers.pkgbuild(), c{
	repl = {
		run = {
			id = "bash.dir:{direncode(args.match_args)}",
			mappings = {
				M = "rm *.zst; makepkg -f && for f in *.zst; do echo $f; tar -tvf $f; done"
			}
		}
	}
})

--
-- julia
--
repl.set_term("julia", {"julia", "-q", "--threads", "12"}, {})

local julia_lsp_start_script = [[
	# Load LanguageServer.jl: attempt to load from ~/.julia/environments/nvim-lspconfig
	# with the regular load path as a fallback
	ls_install_path = joinpath(
		get(DEPOT_PATH, 1, joinpath(homedir(), ".julia")),
		"environments", "nvim-lspconfig"
	)
	pushfirst!(LOAD_PATH, ls_install_path)
	using LanguageServer
	popfirst!(LOAD_PATH)
	depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
	project_path = let
		dirname(something(
			## 1. Finds an explicitly set project (JULIA_PROJECT)
			Base.load_path_expand((
				p = get(ENV, "JULIA_PROJECT", nothing);
				p === nothing ? nothing : isempty(p) ? nothing : p
			)),
			## 2. Look for a Project.toml file in the current working directory,
			##    or parent directories, with $HOME as an upper boundary
			Base.current_project(),
			## 3. First entry in the load path
			get(Base.load_path(), 1, nothing),
			## 4. Fallback to default global environment,
			##    this is more or less unreachable
			Base.load_path_expand("@v#.#"),
		))
	end
	@info "Running language server" VERSION pwd() project_path depot_path
	server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path)
	run(server)
]]
local jl_lsp = mc.register(mft"julia", c{
	lsp = {
		julials = {
			cmd = {"julia", "--startup-file=no", "--history-file=no", "-e", julia_lsp_start_script},
		}
	}
} .. lsp_generic)

mc.register(mft"julia" * mdir"/home/simon/projects/master/glint-jl", c{
	lsp = {
		julials = {
			root_dir = "/home/simon/projects/master/glint-jl"
		}
	}
}):after(jl_lsp)

mc.register(mft"julia", c{
	dap = {
		launch = function(args)
			local modulename = vim.fs.basename(args.file).sub(1, -4)
			local file_directory = vim.fs.dirname(args.file)
			-- set up debug-file.
			os.execute(([[echo 'push!(LOAD_PATH, "%s"); using %s; %s.main()' > /tmp/%s.jl]]):format(file_directory, modulename, modulename, modulename))

			return {
				type = "julia",
				name = "Launch",
				request = "launch",
				program = "/tmp/" .. modulename .. ".jl",
				debugAutoInterpretAllModules = false,
				stopOnEntry = false,
			}
	end
	},
	repl = {
		run = {
			id = "julia",
			type = function(args, repl_id, spec)
				vnoremapsilent_buf(spec.toggle_keys, function()
					-- leave visual.
					-- this has to be done before getting visual, since the markers (<,>) are
					-- only set upon leaving Visual.
					local keys = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
					-- "x" to immediately process keys.
					vim.api.nvim_feedkeys(keys, "x", true)

					repl.send(repl_id, table.concat(require("util").get_visual(), "\n"))
				end)
			end,
			once = function(args, repl_id)
				local module_name = vim.fs.basename(args.file):sub(1, -4)
				local module_dir = vim.fs.dirname(args.file)
				nnoremapsilent_buf(",R", function()
					repl.send(repl_id, ("push!(LOAD_PATH, \"%s\"); using %s"):format(module_dir, module_name))
				end)

				nnoremapsilent_buf("<space>r", function()
					repl.send(repl_id, module_name .. ".main()")
				end)
			end
		}
	}
})

-- separate out to optionally disable.
local julia_ft_using = mc.register(mft"julia", c{
	repl = {
		run = {
			id = "julia",
			once = function(args,repl_id)
				local modulename = vim.fs.basename(args.file):sub(1, -4)
				repl.send(repl_id, "using " .. modulename)
			end
		}
	}
})

--
-- lua
--
mc.register(mft"lua", c{
	dap = {
		attach = {
			type = 'nlua',
			request = 'attach',
			name = "Attach to running Neovim instance",
			host = "127.0.0.1",
			port = function()
				local val = tonumber(vim.fn.input('Port: '))
				assert(val, "Please provide a port number")
				return val
			end,
		}
	}
})

require("matchconfig.options.lsp").set_default_capabilities(vim.tbl_deep_extend("force",
	vim.lsp.protocol.make_client_capabilities(),
	require("blink.cmp").get_lsp_capabilities()
))

local lsp_lua = mc.register(mft"lua", c{
	lsp = {
		lua_ls = {
			enable_per_workspace_config = true,
			cmd = {
				"lua-language-server",
				"--logpath=/home/simon/.cache/lua-language-server/",
				"--metapath=/home/simon/.cache/lua-language-server/meta/",
			},
			root_dir = eval(function(args)
				-- fall back to a workspace that is just the file.
				-- lua_ls can handle this! Cool!!
				return vim.fs.root(args.file, ".git") or args.file
			end),
			settings = {
				Lua = {
					completion = {
						callSnippet = "Replace"
					},
					runtime = {
						version = 'LuaJIT',
						path = {
							"lua/?.lua",
							"lua/?/init.lua",
							-- meta & template seem to refer to /usr/lib/lua-language-server/meta.
							"meta/template/?.lua",
							"meta/template/?/init.lua",
						}
					},
					workspace = {
						-- Make the server aware of Neovim runtime files.
						library = dofile(vim.fn.stdpath("config") .. "/generated/rtp_base.lua"),
						ignoreDir = {
							".cache",
							"deps",
						}
					},
				},
			},
		}
	},
} .. lsp_generic)

local rtp_plugin_data = dofile(vim.fn.stdpath("config") .. "/generated/rtp_plugins.lua")
local full_plugin_luals = c{
	lsp = {
		lua_ls = {
			settings = {
				Lua = {
					workspace = {
						library = merge.list_extend(rtp_plugin_data.all_paths)
					}
				}
			},
			root_dir = eval(function(args)
				return args.match_args[2]
			end)
		}
	}
}
mc.register(mft"lua" * mdir"/home/simon/projects/dotfiles/nvim/lua", full_plugin_luals):after(lsp_lua)
mc.register(mft"lua" * mfile"/home/simon/projects/dotfiles/nvim/configs.lua", full_plugin_luals):after(lsp_lua)

local luasnippet_luals = c{
	lsp = {
		lua_ls = {
			settings = {
				Lua = {
					workspace = {
						library = merge.list_extend({
							vim.fn.stdpath("config") .. "/meta/luasnippets/",
							rtp_plugin_data.path_by_name.luasnip
						})
					}
				}
			},
			root_dir = eval(function(args)
				return args.match_args[2]
			end)
		}
	}
}

mc.register(mft"lua" * mpattern".*/luasnippets/", luasnippet_luals):after(lsp_lua)
mc.register(mft"lua" * mdir"/home/simon/projects/nvim/luasnip-issues", luasnippet_luals):after(lsp_lua)

local luals_mdgen_dir = "/home/simon/projects/luals-mdgen"
local mdgen_luals = c{
	lsp = {
		lua_ls = {
			settings = {
				Lua = {
					runtime = {
						path = merge.list_extend({"?.lua"})
					},
					workspace = {
						library = merge.list_extend({
							luals_mdgen_dir
						})
					}
				}
			},
			root_dir = luals_mdgen_dir
		}
	}
}

mc.register(mft"lua" * mdir(luals_mdgen_dir), mdgen_luals):after(lsp_lua)

--
-- nix
--
repl.set_term_generator("nix_dir", function(term_id)
	local match = term_id:match("nix%.dir%:([^%.]+)")
	if match then
		return {
			cmd = {"nix", "repl"},
			job_opts = {
				cwd = dirdecode(match)
			}
		}
	end
end)
mc.register(mft"nix", c{
	repl = {
		run = {
			id = "nix.dir:{direncode(vim.fs.dirname(args.file))}",
			mappings = {
				["<Space>r"] = ":r\n:p import {args.file}"
			}
		}
	},
	buf_opts = {
		formatoptions = "cqjr",
		expandtab = true,
		tabstop = 2,
		shiftwidth = 2,
	}
})


--
-- cpp
--
mc.register(mft"cpp", c{
	lsp = {
		clangd = {
			cmd = { "clangd" },
		}
	}
} .. lsp_generic)

--
-- python
--
repl.set_term("python", {"ipython"}, {
	-- initial_keys = "%matplotlib\n%matplotlib"
})
mc.register(mft"python", c{
	dap = {
		launch = {
			type = 'python',
			request = 'launch',
			name = 'launch',
			program = '${file}',
			cwd = '${workspaceFolder}',
			env = {
				PYTHONPATH = "${workspaceFolder}"
			},
			justMyCode = false
		}
	}
} .. c{
	repl = {
		run = {
			id = "python",
			type = function(_, repl_id, spec)
				vnoremapsilent_buf(spec.toggle_keys, function()
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
					repl.send(repl_id, lines)
				end)
			end,
			-- send to most-recently registered python-repl (most likely the correct one.)
			mappings = {
				["<space>r"] = [[exec(open("{args.file:gsub("ipynb", "py")}").read())]]
			}
		}
	}
})

mc.register(mft"python", c{
	lsp = {
		pyright = {
			cmd = {"pyright-langserver", "--stdio"},
			settings = {
				python = {
					analysis = {
						autoSearchPaths = false,
						useLibraryCodeForTypes = true,
						diagnosticMode = 'openFilesOnly',
					}
				}
			}
		}
	}
} .. lsp_generic)

--
-- zig
--

local zig_lsp_generic = mc.register(mft"zig", c{
	lsp = {
		zls = {
			cmd = {"zls"},
			settings = {
				force_autofix=true
			}
		}
	},
	run_buf = function()
		autocmd_buf("BufWritePost", function(args)
			local client = vim.lsp.get_clients({bufnr = args.buf, name = "zls"})[1]
			if not client then
				vim.notify("No zls-client available for fixAll!")
			end
			client:request(
				"textDocument/codeAction",
				{
					context = {
						diagnostics = {},
						only = {"source.fixAll"},
						triggerKind=1
					},
					-- range does not seem to matter, it only has to exist!
					range = {
						["end"] = {character = 0, line = 1},
						start = {character = 0, line = 1}
					},
					textDocument = vim.lsp.util.make_text_document_params(args.buf)
				},
				function(err, res)
					if err then
						vim.notify("Error while requesting code-actions! " .. err)
					end
					local first_valid_item = vim.iter(res):find(function(item)
						return item.title == "discard function parameter"
					end)
					local first_valid_edit = first_valid_item and first_valid_item.edit

					-- if there is any edit, apply it.
					if first_valid_edit then
						vim.lsp.util.apply_workspace_edit(first_valid_edit, client.offset_encoding)
						vim.schedule(function()
							vim.cmd("write")
						end)
					end
				end,
				args.buf
			)
		end)
	end
} .. lsp_generic)

local function nix_override_zig(dir)
	local proj_repl_id = "zig-" .. dir

	-- load dev-env.
	-- Preserves completions, and overrides PATH.
	-- For some reason (probably loading-order or something, not surprising
	-- tbh) the first invocation fails in preserving completions, while the
	-- second succeeds.
	-- repl.set_term(proj_repl_id, {"bash", "-c", 'eval "$(nix print-dev-env /home/simon/projects/nix-text/zig); bash"'}, {cwd = dir})
	repl.set_term(proj_repl_id, {"nix", "develop"}, {cwd = dir})
	local dir_mc = mc.register(mdir(dir) * mft"zig", c{
		lsp = {
			zls = {cmd = {"nix", "develop", dir, "--command", "zls"}}
		},
		repl = {
			run = {
				id = proj_repl_id,
				mappings = {
					["<Space>b"] = "zig build",
					["<Space>r"] = "zig build run"
				}
			},
			set_type = {id = proj_repl_id, type = repl_secondary},
		},
	})
	dir_mc:after(zig_lsp_generic)
	return dir_mc
end

nix_override_zig("/home/simon/projects/nix-text/zig")
nix_override_zig("/home/simon/projects/master/glint-vk")
nix_override_zig("/home/simon/projects/test_zig")

--
-- tex
--
mc.register(mft"tex", c{
	run_buf = function()
		usercommand_buf("IG", function(args)
			local source = args.fargs[1]
			local source_new = args.fargs[2]
			if source_new then
				os.execute("cp " .. source .. " " .. source_new)
			else
				-- in case the file should not be moved, but is already at the correct place.
				source_new = source
			end

			ls.snip_expand(
			ls.s("", {
				ls.c(1, {
					ls.parser.parse_snippet(nil, ([[
						{
						\centering
						\includegraphics[width=${1:0.5}\textwidth]{%s}

						} ]]):format(source_new:gsub("%.png", "")), {trim_empty=true, dedent=true}),
					ls.parser.parse_snippet(nil, ([[
						\includegraphics[width=${1:0.5}\textwidth]{%s}
					]]):format(source_new:gsub("%.png", "")), {trim_empty=true, dedent=true})
				})
			})
			 )
		end, {complete = "file", nargs = "+"})
	end,
	buf_opts = {
		textwidth = 120
	}
})

-- temporary!!
local proposal_dir = "/home/simon/projects/master/proposal"
mc.register(mft"tex" * mdir(proposal_dir), c{
	lsp = {texlab = {
		cmd = { "nix", "develop", proposal_dir, "-c", "texlab" },
		filetypes = { "tex", "bib" },
		root_dir = proposal_dir,
		settings = {
			texlab = {
				build = {
					executable = "latexmk",
					args = { "-f", "-shell-escape", "-pdf", "-interaction=nonstopmode", "%f", "-synctex=1" },
					onSave = true,
					onChange = false
				},
				forwardSearch = {
					executable = "zathura",
					args = {"--synctex-forward", "%l:1:%f", "%p"},
					onSave = false
				},
				lint = {
					onChange = false,
					onSave = false
				},
				latexFormatter = "texlab"
			},
		},
	}}
} .. lsp_generic .. c{
	run_buf = function(args)
		autocmd_buf("BufWritePost", function()
			local bufnr = args.buf
			-- should only ever be one.
			local client = vim.lsp.get_clients({bufnr = bufnr, name = "texlab"})[1]
			if not client then
				return vim.notify(('texlab client not found in bufnr %d'):format(bufnr), vim.log.levels.ERROR)
			end
			local win = vim.api.nvim_get_current_win()
			local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
			client:request('textDocument/build', params, function(err, result)
				if err then
				  error(tostring(err))
				end
				local texlab_build_status = {
				  [0] = 'Success',
				  [1] = 'Error',
				  [2] = 'Failure',
				  [3] = 'Cancelled',
				}
				vim.notify('Build ' .. texlab_build_status[result.status], vim.log.levels.INFO)
			end, bufnr)
		end)
	end
})

---
--- CMake
---

local cmake_generic = mc.register(project_matchers.cmake(), cmake_attach("bash.dir:{direncode(args.match_args)}"))
cmake_generic:blacklist_by("project")

---
--- LuaSnip
---

local luasnip_dir = "/home/simon/projects/nvim/luasnip"

repl.set_term("bash.dir:" .. luasnip_dir, {"nix", "develop", luasnip_dir}, {cwd = luasnip_dir})

mc.register(mdir(luasnip_dir), c{
	repl = {
		run = {
			id = "bash.dir:" .. luasnip_dir,
			mappings = {
				T = function()
					local command = "TEST_07=false TEST_09=false make test_nix"
					local file = vim.api.nvim_buf_get_name(0)
					if file:match("_spec%.lua$") then
						command = "TEST_FILE=" .. file .. " " .. command
					end
					return command
				end
			}
		},
		set_type = {id = "bash.dir:" .. luasnip_dir, type = repl_secondary}
	},
	run_buf = function()
		actions.cabbrev_buf("%%", "/home/simon/projects/nvim/luasnip/lua/luasnip")
		actions.cabbrev_buf("!!", "/home/simon/projects/nvim/luasnip/tests/integration")
	end
} )
local luasnip_lua_lsp = mc.register(mdir(luasnip_dir) * mft"lua", c{
	lsp = {
		lua_ls = {
			settings = {
				Lua = {
					workspace = {
						library = merge.list_extend({ luasnip_dir })
					}
				}
			},
			root_dir = luasnip_dir,
		}
	},
})

luasnip_lua_lsp:after(lsp_lua)

---
--- Matchconfig
---

local mc_dir = "/home/simon/projects/nvim/matchconfig"
mc.register(mdir(mc_dir), c{
	run_buf = function()
		local abspath = mc_dir .. "/lua/matchconfig"
		cabbrev_buf("%%", abspath)
	end,
	luasnip_ft_extend = {
		lua = {"matchconfig_lua"}
	}
})

local mc_lua_dir = mc_dir .. "/lua/matchconfig"
mc.register(mdir(mc_lua_dir) * mft"lua", c{
	lsp = {
		lua_ls = {
			settings = {
				Lua = {
					workspace = {
						library = merge.list_extend({ mc_lua_dir })
					}
				}
			},
			root_dir = mc_lua_dir,
		}
	},
})

---
--- Dotfiles-nixos
---

local dotfiles_dir = "/home/simon/projects/dotfiles/nixos"
mc.register(mdir(dotfiles_dir), c{
	run_buf = function()
		cabbrev_buf("%%", dotfiles_dir)
	end,
	repl = {
		run = {
			id = "bash.dir:" .. direncode(dotfiles_dir),
			mappings = {
				["R"] = "re"
			}
		},
		set_type = {id = "bash.dir:" .. direncode(dotfiles_dir), type = repl_secondary}
	}
})

---
--- Sway
---
local sway_reload_on_write = c{
	run_buf = function()
		autocmd_buf("BufWritePost", function()
				os.execute("SWAYSOCK=/run/user/1000/sway-ipc.1000.$(pidof sway).sock swaymsg reload")
			end
		)
	end
}

mc.register(mdir"/home/simon/.config/sway", sway_reload_on_write)
mc.register(mdir"/home/simon/.config/waybar", sway_reload_on_write)

mc.register(mdir"/home/simon/projects/termpick", c{
	repl = {
		run = {
			type = "bash.dir:{direncode(args.match_args)}",
			mappings = {
				["<Space>r"] = "zig build run"
			}
		}
	},
	run_buf = function()
		cabbrev_buf("%%", "/home/simon/projects/termpick/src")
		cabbrev_buf("%m", "/home/simon/projects/termpick/src/main.zig")
	end
})

mc.register(mdir"/home/simon/Packages/Anna Gebertz", c{
	run_buf = function()
		autocmd_buf("BufWritePost", function()
				os.execute("qutebrowser -s new_instance_open_target tab-silent  :reload 2> /dev/null")
			end
		)
	end
})

local cuora_dir = "/home/simon/projects/cuora"
repl.set_term("bash.cwd:" .. cuora_dir, {"bash"}, {
	cwd = cuora_dir
})
local cuora = mc.register(mdir(cuora_dir), c{
	run_buf = function()
		nnoremapsilent_buf("<space>s", function()
			os.execute("imv out.svg &")
		end)
		cabbrev_buf("%%", "/home/simon/projects/cuora/src")
		cabbrev_buf("%m", "/home/simon/projects/cuora/src/main.zig")
	end,
	dap = {
		launch = {
			name = "cuora",
			type = "lldb",
			request = "launch",
			program = "zig-out/bin/cuora",
			cwd = '${workspaceFolder}',
		}
	},
	repl = {
		run = {
			id = "bash.cwd:" .. cuora_dir,
			once = function(_, term_id)
				nnoremapsilent_buf("<space>r", function()
					repl.send(term_id, "zig build run")
					if util.process_output("pidof imv-wayland") == "" then
						repl.send(term_id, "imv out.svg &")
					end
				end)
			end,
			mappings = {
				["<space>b"] = "zig build"
			}
		}
	}
})

local cuora_zig = mc.register(mdir(cuora_dir) * mft"zig", c{
	lsp = {
		zls = {
			root_dir = cuora_dir
		}
	},
})
cuora_zig:after(zig_lsp_generic)

---
--- Mitsuba
---

local mitsuba_lab_dir =  "/mnt/misc/old_stuff/s10/lab/mitsuba3"
repl.set_term("bash.mitsuba", {"bash"}, {
	cwd = mitsuba_lab_dir .. "",
	env = {PYTHONPATH=mitsuba_lab_dir .. "/build/python:" .. mitsuba_lab_dir .. "/py_modules"}
})

local lab_mitsuba = mc.register(mdir(mitsuba_lab_dir), cmake_attach("bash.mitsuba", {
	debug = true,
	cmake_args = {"MI_DEFAULT_VARIANTS=\"scalar_spectral;scalar_rgb;cuda_spectral;llvm_spectral;llvm_spectral_polarized\""},
	mappings = {
		["<space>r"] =  "make run M=rgb_rect"
	}
}) .. c{
	run_buf = function()
		usercommand_buf("T", function()
			util.process_output("systemd-run --user -u tev /home/simon/.local/bin/sway_float tev")
		end, {})
		cabbrev_buf("%%", mitsuba_lab_dir .. "/src")
		cabbrev_buf("##", mitsuba_lab_dir .. "/scripts")
		cabbrev_buf("!!", mitsuba_lab_dir .. "/include/mitsuba/render")
		cabbrev_buf("@@", mitsuba_lab_dir .. "/scenes")
		cabbrev_buf("%p", mitsuba_lab_dir .. "/src/plt")
		cabbrev_buf("%b", mitsuba_lab_dir .. "/src/bsdfs")
	end,
	luasnip_ft_extend = {
		cpp = {"cpp_mitsuba"}
	},
	dap = {
		launch = {
			name = "rgb_rect-scalar",
			type = "lldb",
			request = "launch",
			program = "build_d/mitsuba",
			args = {"-m",
					"scalar_spectral", "-t", "1",
					"-D",
					"spp=1",
					"-D",
					"width=512",
					"-D",
					"height=512",
					"-o",
					"out.exr",
					mitsuba_lab_dir .. "/scenes/rgb_rect.xml"},
			cwd = '${workspaceFolder}',
		},
		launch_simple = {
			name = "simple-scalar",
			type = "lldb",
			request = "launch",
			program = "build_d/mitsuba",
			args = {"-m",
					"scalar_spectral", "-t", "1",
					"-D",
					"spp=1",
					"-D",
					"width=512",
					"-D",
					"height=512",
					"-o",
					"out.exr",
					mitsuba_lab_dir .. "/scenes/simple.xml"},
			cwd = '${workspaceFolder}',
		},
		launch_llvm = {
			name = "rgb_rect-llvm",
			type = "lldb",
			request = "launch",
			program = "build_d/mitsuba",
			args = {"-m",
					"llvm_spectral", "-t", "1",
					"-D",
					"width=512",
					"-D",
					"height=512",
					"-o",
					"out.exr",
					mitsuba_lab_dir .. "/scenes/rgb_rect.xml"},
			cwd = '${workspaceFolder}',
		},
		launch_llvm_O0 = {
			name = "rgb_rect-llvm-O0",
			type = "lldb",
			request = "launch",
			program = "build_d/mitsuba",
			args = {"-m",
					"llvm_spectral", "-t", "1", "-O", "0",
					"-D",
					"width=512",
					"-D",
					"height=512",
					"-o",
					"out.exr",
					mitsuba_lab_dir .. "/scenes/rgb_rect.xml"},
			cwd = '${workspaceFolder}',
		},
		launch_simple_py = {
			name = "simple-python",
			type = "lldb",
			request = "launch",
			program = "/usr/bin/python",
			stopOnEntry = true,
			args = {mitsuba_lab_dir .. "/scripts/simple.py"},
			cwd = '${workspaceFolder}',
			-- load debug version!! :D
			env = {"PYTHONPATH=/home/simon/Documents/Uni/Kurse/s10/lab/mitsuba3/py_modules:/home/simon/Documents/Uni/Kurse/s10/lab/mitsuba3/build_d/python"}
		},
		launch_cbox_py = {
			name = "cbox-python",
			type = "lldb",
			request = "launch",
			program = "/usr/bin/python",
			stopOnEntry = true,
			args = {mitsuba_lab_dir .. "/scripts/cornell_box.py"},
			cwd = '${workspaceFolder}',
			-- load debug version!! :
			env = {"PYTHONPATH=/home/simon/Documents/Uni/Kurse/s10/lab/mitsuba3/py_modules:/home/simon/Documents/Uni/Kurse/s10/lab/mitsuba3/build_d/python"}
		},
		launch_gausstest_py = {
			name = "gaussdielectric-python",
			type = "lldb",
			request = "launch",
			program = "/usr/bin/python",
			stopOnEntry = true,
			args = {mitsuba_lab_dir .. "/scripts/gaussian_test.py"},
			cwd = '${workspaceFolder}',
			-- load debug version!! :
			env = {"PYTHONPATH=/home/simon/Documents/Uni/Kurse/s10/lab/mitsuba3/py_modules:/home/simon/Documents/Uni/Kurse/s10/lab/mitsuba3/build_d/python"}
		},
		launch_gratingtest_py = {
			name = "grating-python",
			type = "lldb",
			request = "launch",
			program = "/usr/bin/python",
			stopOnEntry = true,
			args = {mitsuba_lab_dir .. "/scripts/grating_test.py"},
			cwd = '${workspaceFolder}',
			-- load debug version!! :
			env = {"PYTHONPATH=/home/simon/Documents/Uni/Kurse/s10/lab/mitsuba3/py_modules:/home/simon/Documents/Uni/Kurse/s10/lab/mitsuba3/build_d/python"}
		},
		launch_gratingtest2_py = {
			name = "grating2-python",
			type = "lldb",
			request = "launch",
			program = "/usr/bin/python",
			stopOnEntry = true,
			args = {mitsuba_lab_dir .. "/scripts/grating_test2.py"},
			cwd = '${workspaceFolder}',
			-- load debug version!! :
			env = {"PYTHONPATH=/home/simon/Documents/Uni/Kurse/s10/lab/mitsuba3/py_modules:/home/simon/Documents/Uni/Kurse/s10/lab/mitsuba3/build_d/python"}
		}
	}
}, {tags = {"project"}})

repl.set_term("python.mitsuba", {"ipython"}, {
	env = {PYTHONPATH = mitsuba_lab_dir .. "/build/python:" .. mitsuba_lab_dir .. "/py_modules", }
})
local mitsuba_py = mc.register(mft"python" * mdir(mitsuba_lab_dir),
	c{
		repl = {
			run = {
				id = "bash.mitsuba",
				mappings = {
					["<space>r"] = "make build && python {args.file} 2> /dev/null"
				}
			},
		}
	} .. c{
		repl = {
			run = {
				-- register override
				id = "python.mitsuba",
			},
		},
	}
)

lab_mitsuba:after("filetype(python)")
mitsuba_py:after(lab_mitsuba)


---
--- .packages
---

-- for PKGBUILDS of my packages.
local pkgbuild_all = mc.register(
	mpattern("^/home/simon/.packages/[^/]+/[^/]+/") * project_matchers.pkgbuild(),
	c{
		repl = {
			run = {
				id = "bash.dir:{direncode(args.match_args[2])}",
				mappings = {
					U = "dbpush *.zst"
				}
			}
		}
	})
local pkgbuild_local = mc.register(
	mpattern("^/home/simon/.packages/local/[^/]+/") * project_matchers.pkgbuild(),
	c{
		repl = {
			run = {
				id =  "bash.dir:{direncode(args.match_args[2])}",
				mappings = {
					U = "p -U $(l *.zst -t | head -n 1) --dbonly --noconfirm && dbpush *.zst"
				}
			}
		}
	})

pkgbuild_all:before(pkgbuild_local)


---
--- zot7fuse
---
mc.register(mfile"/home/simon/projects/zot7fuse/init.py", c{
	dap = {
		launch = {
			type = 'python',
			request = 'launch',
			name = 'launch',
			program = '${file}',
			cwd = '${workspaceFolder}',
			justMyCode = false,
			args = {"mnt"}
		}
	},
	lsp = {
		pyright = {
			root_dir = "/home/simon/projects/zot7fuse"
		}
	}
})

---
--- projects/master
---

local proj_master_dir = "/home/simon/projects/master/glint-jl"
mc.register(matchers.dir(proj_master_dir), c{
	run_buf = function()
		actions.cabbrev_buf("%%", proj_master_dir .. "/src")
	end
})

repl.set_term("julia.pm", {"nix", "develop", proj_master_dir}, {cwd = proj_master_dir, initial_keys = "julia -q --threads 11\nusing Pkg; Pkg.activate(\"" .. proj_master_dir .. "\"); using glint"})
local master = mc.register(matchers.dir(proj_master_dir) * mft("julia"), c{
	repl = {run = {
		mappings = {
			["<Space>r"] = [[{args.file:match("[^/]+$"):sub(1, -4)}_main()]]
		},
		id = "julia.pm"
	},
	set_type = {id = "julia.pm", type = repl_secondary}},
	run_buf = function()
		usercommand_buf("T", function()
			-- make sure to resolve tev-path here.
			-- systemd, where sway_float executes, may have different PATH (NixOS).
			util.process_output("systemd-run --user -u tev sway_float $(which tev)")
		end, {})
	end
})
master:after("filetype(julia)")
master:blacklist(julia_ft_using)

---
---projects/panvimdoc
---
mc.register(mdir("/home/simon/projects/panvimdoc"), c{
	buf_opts = {
		expandtab = true,
		tabstop = 2,
		shiftwidth = 2,
	}
})

---
--- Grip
---

local grip_conf = c{
	run_buf = function(args)
		usercommand_buf("Gr", function()

			-- 0: run on random port.
			print(util.process_output(
				"systemd-run --user -u $(systemd-escape grip_" .. args.file .. ") " ..
				"grip -b " .. args.file .. " 0 2> /dev/null"))
			print("Starting grip for " .. args.file)
		end, {})
		usercommand_buf("S", function()
			util.process_output(
				"systemctl --user stop $(systemd-escape grip_" .. args.file .. ")")
			print("Stopping grip for " .. args.file)
		end, {})
	end
}

mc.register(matchers.pattern("README.md$"), grip_conf)
mc.register(matchers.pattern("DOC.md$"), grip_conf)
