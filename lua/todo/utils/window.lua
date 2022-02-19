local buffer = require "todo.utils.buffer"

local window = {}

window.is_floating = function(win)
	local opts = vim.api.nvim_win_get_config(win)
	return opts and opts.relative and opts.relative ~= ""
end

window.is_valid = function(win, excluded_filetypes)
	if not vim.api.nvim_win_is_valid(win) then
		return false
	end

	-- ignore floating windows
	if window.is_floating(win) then
		return false
	end

	local buf = vim.api.nvim_win_get_buf(win)
	return buffer.is_valid(buf, excluded_filetypes)
end

return window
