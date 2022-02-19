local utils = require "todo-comments.utils"
local default_config = require "todo-comments.config.default"

local config = {}

config.keywords = {}
config.options = {}
config.is_loaded = false
-- Used for highlight groups
config.namespace = vim.api.nvim_create_namespace("todo-comments")
config.rg_regex = nil
config.hl_regex = nil

config.setup = function(opts)
	config.options = vim.tbl_deep_extend("force", {}, default_config, config.options, opts)

	-- fully override keywords
	if opts.keywords and opts.merge_keywords == false then
		config.options.keywords = opts.keywords
	end

	-- extract the list of keywords (with alternatives)
	for kw, kw_opts in pairs(config.options.keywords) do
		config.keywords[kw] = kw
		for _, alt in pairs(kw_opts.alt or {}) do
			-- alternatives get the same config of the original
			config.keywords[alt] = kw
		end
	end

	-- build searching and highlighting regex patterns
	local kw_regex = table.concat(vim.tbl_keys(config.keywords), "|")
	config.rg_regex = config.options.search.pattern:gsub("KEYWORDS", kw_regex)
	config.hl_regex = {}
	local hl_patterns = config.options.highlight.pattern
	hl_patterns = type(hl_patterns) == "table" and hl_patterns or { hl_patterns }
	for _, pattern in pairs(hl_patterns) do
		pattern = pattern:gsub("KEYWORDS", kw_regex)
		table.insert(config.hl_regex, pattern)
	end

	config.colors()
	config.signs()
	config.is_loaded = true
end

config.colors = function()
	local normal_hl = utils.highlight.get("Normal", { fg = "#ffffff", bg = "#000000" })
	local fg_dark = utils.color.is_dark(normal_hl.fg) and normal_hl.fg or normal_hl.bg
	local fg_light = utils.color.is_dark(normal_hl.fg) and normal_hl.bg or normal_hl.fg

	local sign_hl = utils.highlight.get("SignColumn", { bg = "NONE" })

	for kw, kw_opts in pairs(config.options.keywords) do
		local kw_color = kw_opts.color or "default"
		local hex

		if utils.color.is_hex(kw_color) then
			hex = kw_color
		else
			local colors = config.options.colors[kw_color]
			colors = type(colors) == "string" and { colors } or colors

			for _, color in pairs(colors) do
				if utils.color.is_hex() then
					hex = color
					break
				end
				local color_hl = utils.highlight.get(color)
				if color_hl.fg then
					hex = color_hl.fg
					break
				end
			end
		end

		if not hex then
			utils.log.warn("Color for keyword " .. kw .. "not found.")
			-- Use default color
			hex = "#000000"
		end

		local fg = utils.color.is_dark(hex) and fg_light or fg_dark

		utils.highlight.create("TODOBg" .. kw, hex, fg, "bold")
		utils.highlight.create("TODOFg" .. kw, "NONE", hex, "NONE")
		utils.highlight.create("TODOSign" .. kw, sign_hl.bg, hex, "NONE")
	end
end

config.signs = function()
	for kw, kw_opts in pairs(config.options.keywords) do
		vim.fn.sign_define("todo-sign-" .. kw, {
			text = kw_opts.icon,
			texthl = "TODOSign" .. kw
		})
	end
end

return config
