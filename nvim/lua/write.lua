-- stolen from @wincent

local cache_time = 5 * 60 * 1000 -- 5 minutes
local password = nil
local timer = nil

local expect = function(expected, fn, description)
	local result = fn()
	if result ~= expected then
		error(
			'error: wincent.sudo.write got result ' .. result .. ' for ' .. description .. '(expected ' .. expected .. ')'
		)
	end
end

local reject = function(rejected, fn, description)
	local result = fn()
	if result == rejected then
		error(
			'error: wincent.sudo.write got result ' .. result .. ' for ' .. description .. '(expected non-' .. rejected .. ')'
		)
	end
end

local write = function(args)
	local bang = args.bang
	if bang or password == nil then
		password = vim.fn.inputsecret('Password:')
		if timer ~= nil then
			timer:stop()
		end
		timer = vim.defer_fn(function()
			password = nil
		end, cache_time)
	end

	local askpass = vim.fn.tempname()

	expect(0, function()
		return vim.fn.writefile({ '' }, askpass, 's')
	end, 'writefile (touch)')
	reject(0, function()
		return vim.fn.setfperm(askpass, 'rwx------')
	end, 'setfperm')
	expect(0, function()
		return vim.fn.writefile({ '#!/bin/bash', 'builtin echo -n ' .. vim.fn.shellescape(password) }, askpass, 's')
	end, 'writefile (fill)')

	local buftype = vim.o.buftype
	if buftype == '' then
		-- Avoid `:help W12` warning.
		vim.opt_local.buftype = 'nowrite'
	end

	vim.api.nvim_create_autocmd("BufEnter", {command = "set noro", buffer = 0})

	pcall(function()
		vim.cmd('silent write !env SUDO_ASKPASS=' .. vim.fn.shellescape(askpass) .. '	sudo -A tee % > /dev/null')
	end)

	if vim.v.shell_error ~= 0 then
		-- Common cause of this is wrong password, so invalidate the cache.
		password = nil
		if timer ~= nil then
			timer:stop()
		end

		if buftype == '' then
			vim.opt_local.buftype = buftype
		end
	else
		if buftype == '' then
			vim.cmd('edit')
			vim.opt_local.buftype = buftype
		end
	end

	expect(0, function()
		return vim.fn.delete(askpass)
	end, 'delete')
end

vim.api.nvim_create_user_command("W", write, {bang = true})
