function Insp(data)
	print(vim.inspect(data))
end

function Do_nvim_relative(filename)
	return dofile("/home/simon/.config/nvim/lua/"..filename)
end
