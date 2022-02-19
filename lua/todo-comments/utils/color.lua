local M = {}

M.hex_to_rgb = function(hex)
	hex = hex:gsub("#", "")
	local r = tonumber("0x" .. hex:sub(1, 2))
	local g = tonumber("0x" .. hex:sub(3, 4))
	local b = tonumber("0x" .. hex:sub(5, 6))
	return r, g, b
end

M.rgb_to_hex = function(r, g, b)
	return string.format("#%02x%02x%02x", r, g, b)
end

M.is_dark = function(hex)
	local r, g, b = M.hex_to_rgb(hex)
	local lumination = (0.299 * r + 0.587 * g + 0.114 * b) / 255
	return lumination <= 0.5
end

M.is_hex = function(color)
	return type(color) == "string" and color:sub(1, 1) == "#" and #color == 7
end

return M
