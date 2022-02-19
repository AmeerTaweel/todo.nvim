local M = {}

function M.exists(name)
	local exists, _ = pcall(vim.api.nvim_get_hl_by_name, name, true)
	return exists
end

-- returns highlight by name if exists, otherwise returns a default highlight
function M.get(name, default)
	local exists, hl = pcall(vim.api.nvim_get_hl_by_name, name, true)

	local result = default or {}

	if not exists then
		return result
	end

	result.fg = hl["foreground"] and string.format("#%06x", hl["foreground"]) or result.fg
	result.bg = hl["background"] and string.format("#%06x", hl["background"]) or result.bg

	return result
end

return M