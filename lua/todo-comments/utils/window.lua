local Buffer = require "todo-comments.utils.buffer"

local M = {}

M.is_floating = function(win)
	local opts = vim.api.nvim_win_get_config(win)
	return opts and opts.relative and opts.relative ~= ""
end

M.is_valid = function(win, excluded_filetypes)
	if not vim.api.nvim_win_is_valid(win) then
		return false
	end

	-- ignore floating windows
	if M.is_floating(win) then
		return false
	end

	local buf = vim.api.nvim_win_get_buf(win)
	return Buffer.is_valid(buf, excluded_filetypes)
end

return M
