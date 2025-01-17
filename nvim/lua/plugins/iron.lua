local iron = require("iron")

iron.core.add_repl_definitions{
	julia = {
		my_julia = {
			command = {"julia", "-q", "-J/home/simon/.julia/sysimages/GLMakieImage.so"}
		}
	}
}

iron.core.set_config{
	preferred = {
		julia = "my_julia"
	},
	repl_open_cmd = "below 15 split"
}

vim.keymap.set("n", ",i", function()
	iron.core.repl_for(vim.bo.ft)
end)
