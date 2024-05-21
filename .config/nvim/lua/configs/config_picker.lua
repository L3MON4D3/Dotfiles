local util = require("util")

local ConfigPicker = {}

local str_parsers = {}
local strs = {}
function ConfigPicker.get_parser(fname)
	if not str_parsers[fname] then
		strs[fname] = util.lines(fname)
		local configs_parser = vim.treesitter.get_string_parser(strs[fname], "lua")
		str_parsers[fname] = configs_parser
	end

	return str_parsers[fname], strs[fname]
end
function ConfigPicker.reset(fname)
	-- remove old parser.
	str_parsers[fname] = nil
	strs[fname] = nil
end
function ConfigPicker.get_config_sources(buf)
	local buf_sources = Config(buf).sources
	local source_ranges = {}
	for i, source in ipairs(buf_sources) do
		local q = ([[
			(field
			  name: (_) @name
			  value: (table_constructor
				(field
				  name: (_) @nested_name
				  value: (_) @def ))

			  (#any-of? @name "%s" "\"%s\"")
			  (#any-of? @nested_name "%s" "\"%s\"")
			)
		]]):format(source.type, source.type, source.id, source.id)
		local query = vim.treesitter.query.parse("lua", q)
		local str_parser, str = ConfigPicker.get_parser(source.fname)
		local parser = str_parser:parse()
		for id, node, _ in query:iter_captures(parser[1]:root(), str) do
			if query.captures[id] == "def" then
				-- there should only be one match
				source_ranges[i] = {fname = source.fname, type = source.type, id = source.id, range = {node:range()}}
				break
			end
		end
	end

	return source_ranges
end

function ConfigPicker.pick_current()
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local entry_display = require("telescope.pickers.entry_display")

	local bufnr = vim.api.nvim_get_current_buf()

	local config_sources = ConfigPicker.get_config_sources(bufnr)
	local opts = {}

	local displayer = entry_display.create {
		separator = " ",
		items = {
			{width = #("filetype")},
			{remaining = true}
		}
	}

	local make_display = function(entry)
		return displayer {
			{entry.type, "TelescopeResultsNumber"},
			entry.id
		}
	end

	local function entry_maker(item)
		return {
			value = item.id,
			display = make_display,
			ordinal = item.id,
			filename = item.fname,
			lnum = item.range[1]+1,
			lnend = item.range[3]+1,
			col = item.range[2]+1,
			colend = item.range[4]+1,
			type = item.type,
			id = item.id
		}
	end

	pickers.new(opts, {
		prompt_title = "Configurations",
		finder = finders.new_table({
			results = config_sources,
			entry_maker = entry_maker
		}),
		previewer = conf.qflist_previewer(opts),
		sorter = conf.generic_sorter(opts)
	}):find()
end

return ConfigPicker
