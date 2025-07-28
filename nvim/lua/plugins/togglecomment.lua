local tc = require("togglecomment")
vim.keymap.set({"n","v"}, "<leader>d", tc.comment, {noremap = true, silent = true})

tc.log.set_loglevel("debug")
require("togglecomment.dev")

-- ---@type Togglecomment.Config
-- local conf = {}

-- tc.setup(conf)
