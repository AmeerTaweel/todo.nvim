local M = {}

local log = function(msg, highlight)
	vim.api.nvim_echo({
		{ "todo.nvim: ", highlight },
		{ msg }
	}, true, {})
end

M.warn = function(msg)
	M.log(msg, "WarningMsg")
end

M.error = function(msg)
	M.log(msg, "ErrorMsg")
end

return M
