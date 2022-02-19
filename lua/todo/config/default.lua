local M = {}

M.signs = {
	enable = true, -- show icons in the signs column
	priority = 8 -- sign priority
}

-- keywords recognized as todo comments
M.keywords = {
	FIX = {
		icon = " ", -- icon used for the sign, and in search results
		color = "error", -- can be a hex color, or a named color (see below)
		alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } -- a set of other keywords that all map to this FIX keywords
		-- signs = false -- configure signs for some keywords individually
	},
	TODO = { icon = " ", color = "info" },
	HACK = { icon = " ", color = "warning" },
	WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
	PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
	NOTE = { icon = " ", color = "hint", alt = { "INFO" } }
}

M.merge_keywords = true -- when true, custom keywords will be merged with the defaults

-- highlighting of the line containing the todo comment
-- * before: highlights before the keyword (typically comment characters)
-- * keyword: highlights of the keyword
-- * after: highlights after the keyword (todo text)
M.highlight = {
	before = "", -- "fg" or "bg" or empty
	keyword = "wide", -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
	after = "fg", -- "fg" or "bg" or empty
	-- pattern can be a string, or a table of regexes that will be checked
	pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlightng (vim regex)
	-- pattern = { [[.*<(KEYWORDS)\s*:]], [[.*\@(KEYWORDS)\s*]] }, -- pattern used for highlightng (vim regex)
	comments_only = true, -- this applies the pattern only inside comments using `commentstring` option
	max_line_len = 400, -- ignore lines longer than this
	exclude = {} -- list of file types to exclude highlighting
}

-- list of named colors where we try to extract the guifg from the
-- list of hilight groups or use the hex color if hl not found as a fallback
M.colors = {
	error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
	warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
	info = { "DiagnosticInfo", "#2563EB" },
	hint = { "DiagnosticHint", "#10B981" },
	default = { "Identifier", "#7C3AED" }
}

M.search = {
	-- regex that will be used to match keywords.
	-- don't replace the (KEYWORDS) placeholder
	pattern = [[\b(KEYWORDS):]] -- ripgrep regex
	-- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
}

return M
