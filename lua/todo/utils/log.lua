local log = {}

local print = function(msg, highlight)
	vim.api.nvim_echo({
		{ "todo.nvim: ", highlight },
		{ msg }
	}, true, {})
end

log.warn = function(msg)
	print(msg, "WarningMsg")
end

log.error = function(msg)
	print(msg, "ErrorMsg")
end

return log
