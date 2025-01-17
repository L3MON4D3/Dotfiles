local dap = require("dap")
dap.configurations.lua = {
	{
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

dap.adapters.nlua = function(callback, config)
	callback({ type = 'server', host = config.host, port = config.port })
end

vim.cmd [[command! DLL :lua require"osv".launch()]]
