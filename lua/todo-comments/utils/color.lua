local M = {}

M.hexToRGB = function(hex)
	hex = hex:gsub("#", "")
	local r = tonumber("0x" .. hex:sub(1, 2))
	local g = tonumber("0x" .. hex:sub(3, 4))
	local b = tonumber("0x" .. hex:sub(5, 6))
	return r, g, b
end

M.rgbToHex = function(r, g, b)
	return string.format("#%02x%02x%02x", r, g, b)
end

M.is_dark = function(hex)
	local r, g, b = M.hexToRGB(hex)
	local lumination = (0.299 * r + 0.587 * g + 0.114 * b) / 255
	return lumination <= 0.5
end

return M
