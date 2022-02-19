local utils = require "todo-comments.utils"
local default_config = require "todo-comments.config.default"

local M = {}

M.keywords = {}
M.options = {}
M.is_loaded = false
-- Used for highlight groups
M.namespace = vim.api.nvim_create_namespace("todo-comments")
M.rg_regex = nil
M.hl_regex = nil

function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", {}, default_config, M.options, opts)

	-- fully override keywords
	if opts.keywords and opts.merge_keywords == false then
		M.options.keywords = opts.keywords
	end

	-- extract the list of keywords (with alternatives)
	for kw, kw_opts in pairs(M.options.keywords) do
		M.keywords[kw] = kw
		for _, alt in pairs(kw_opts.alt or {}) do
			-- alternatives get the same config of the original
			M.keywords[alt] = kw
		end
	end

	-- build searching and highlighting regex patterns
	local kw_regex = table.concat(vim.tbl_keys(M.keywords), "|")
	M.rg_regex = M.options.search.pattern:gsub("KEYWORDS", kw_regex)
	M.hl_regex = {}
	local hl_patterns = M.options.highlight.pattern
	hl_patterns = type(hl_patterns) == "table" and hl_patterns or { hl_patterns }
	for _, pattern in pairs(hl_patterns) do
		pattern = pattern:gsub("KEYWORDS", kw_regex)
		table.insert(M.hl_regex, pattern)
	end

	M.setup_colors()
	M.setup_signs()
	M.is_loaded = true
end

function M.setup_colors()
	local normal_hl = utils.highlight.get("Normal", { fg = "#ffffff", bg = "#000000" })
	local fg_dark = utils.color.is_dark(normal_hl.fg) and normal_hl.fg or normal_hl.bg
	local fg_light = utils.color.is_dark(normal_hl.fg) and normal_hl.bg or normal_hl.fg

	local sign_hl = utils.highlight.get("SignColumn", { bg = "NONE" })

	for kw, kw_opts in pairs(M.options.keywords) do
		local kw_color = kw_opts.color or "default"
		local hex

		if utils.color.is_hex(kw_color) then
			hex = kw_color
		else
			local colors = M.options.colors[kw_color]
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

function M.setup_signs()
	for kw, kw_opts in pairs(M.options.keywords) do
		vim.fn.sign_define("todo-sign-" .. kw, {
			text = kw_opts.icon,
			texthl = "TODOSign" .. kw
		})
	end
end

return M
