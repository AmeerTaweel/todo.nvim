local M = {}

M.is_quickfix = function(buf)
	return vim.api.nvim_buf_get_option(buf, "buftype") == "quickfix"
end

M.is_valid = function(buf, excluded_filetypes)
	-- ignore special buffers
	local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
	if buftype ~= "" and buftype ~= "quickfix" then
		return false
	end

	-- ignore excluded filetypes
	local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
	if vim.tbl_contains(excluded_filetypes or {}, filetype) then
		return false
	end

	return true
end

return M
