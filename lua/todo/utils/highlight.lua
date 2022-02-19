local highlight = {}

function highlight.exists(name)
	local exists, _ = pcall(vim.api.nvim_get_hl_by_name, name, true)
	return exists
end

-- returns highlight by name if exists, otherwise returns a default highlight
function highlight.get(name, default)
	local exists, hl = pcall(vim.api.nvim_get_hl_by_name, name, true)

	local result = default or {}

	if not exists then
		return result
	end

	result.fg = hl["foreground"] and string.format("#%06x", hl["foreground"]) or result.fg
	result.bg = hl["background"] and string.format("#%06x", hl["background"]) or result.bg

	return result
end

function highlight.create(name, guibg, guifg, gui)
	vim.cmd("hi def " .. name .. " guibg=" .. guibg .. " guifg=" .. guifg .. " gui=" .. gui)
end

function highlight.add(buf, namespace, highlight, line, from, to)
	vim.api.nvim_buf_add_highlight(buf, namespace, highlight, line, from, to)
end

return highlight
