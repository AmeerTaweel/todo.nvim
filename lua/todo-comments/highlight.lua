local config = require "todo-comments.config"
local utils = require "todo-comments.utils"

local highlight = {}

highlight.enabled = false
highlight.buffers = {}
highlight.windows = {}

function highlight.match(str, patterns)
	local max_line_len = config.options.highlight.max_line_len

	if max_line_len and #str > max_line_len then
		return
	end

	patterns = patterns or config.hl_regex
	if not type(patterns) == "table" then
		patterns = { patterns }
	end

	for _, pattern in pairs(patterns) do
		local m = vim.fn.matchlist(str, [[\v\C]] .. pattern)
		if #m > 1 and m[2] then
			local kw = m[2]
			local start = str:find(kw)
			local finish = start + #kw
			return start, finish, kw
		end
	end
end

-- highlights range in the given buffer
function highlight.buffer(buf, first, last, _event)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	vim.api.nvim_buf_clear_namespace(buf, config.namespace, first, last + 1)

	-- clear signs
	for _, sign in pairs(vim.fn.sign_getplaced(buf, { group = "todo-signs" })[1].signs) do
		if sign.lnum - 1 >= first and sign.lnum - 1 <= last then
			vim.fn.sign_unplace("todo-signs", { buffer = buf, id = sign.id })
		end
	end

	local lines = vim.api.nvim_buf_get_lines(buf, first, last + 1, false)

	for l, line in ipairs(lines) do
		local ok, start, finish, kw = pcall(highlight.match, line)
		local lnum = first + l - 1

		if ok and start and config.options.highlight.comments_only
			and not utils.buffer.is_quickfix(buf)
			and utils.treesitter.is_comment(buf, lnum) == false
		then
			kw = nil
		end

		if kw then
			kw = config.keywords[kw] or kw
		end

		local opts = config.options.keywords[kw]

		if opts then
			start = start - 1
			finish = finish - 1

			local hl_fg = "TODOFg" .. kw
			local hl_bg = "TODOBg" .. kw

			local hl = config.options.highlight

			-- highlights before keyword
			if hl.before == "fg" then
				utils.highlight.add(buf, config.namespace, hl_fg, lnum, 0, start)
			elseif hl.before == "bg" then
				utils.highlight.add(buf, config.namespace, hl_bg, lnum, 0, start)
			end

			-- highlights keyword
			if hl.keyword == "wide" then
				finish = finish + 1
				utils.highlight.add(buf, config.namespace, hl_bg, lnum, start, finish)
			elseif hl.keyword == "bg" then
				utils.highlight.add(buf, config.namespace, hl_bg, lnum, start, finish)
			elseif hl.keyword == "fg" then
				utils.highlight.add(buf, config.namespace, hl_fg, lnum, start, finish)
			end

			-- highlights after keyword
			if hl.after == "fg" then
				utils.highlight.add(buf, config.namespace, hl_fg, lnum, finish, #line)
			elseif hl.after == "bg" then
				utils.highlight.add(buf, config.namespace, hl_bg, lnum, finish, #line)
			end

			-- signs
			local show_sign = config.options.signs.enable
			if opts.signs ~= nil then
				show_sign = opts.signs
			end
			if show_sign then
				vim.fn.sign_place(
					0,
					"todo-signs",
					"todo-sign-" .. kw,
					buf,
					{ lnum = lnum + 1, priority = config.options.signs.priority }
				)
			end
		end
	end
end

-- highlights visible range of window
function highlight.window(win, force)
	win = win or vim.api.nvim_get_current_win()
	local excluded_filetypes = config.options.highlight.exclude
	if force ~= true and not utils.window.is_valid(win, excluded_filetypes) then
		return
	end

	local current_win = vim.api.nvim_get_current_win()
	vim.api.nvim_set_current_win(win)

	local buf = vim.api.nvim_win_get_buf(win)
	local first = vim.fn.line("w0") - 1
	local last = vim.fn.line("w$")
	highlight.buffer(buf, first, last)

	vim.api.nvim_set_current_win(current_win)
end

-- attach to window buffer and highlight the active buf if needed
function highlight.attach(win)
	win = win or vim.api.nvim_get_current_win()
	local excluded_filetypes = config.options.highlight.exclude
	if not utils.window.is_valid(win, excluded_filetypes) then
		return
	end

	local buf = vim.api.nvim_win_get_buf(win)

	if not highlight.buffers[buf] then
		vim.api.nvim_buf_attach(buf, false, {
			on_lines = function(_event, _buf, _tick, first, _last, last_new)
				if not highlight.enabled then
					return true
				end

				-- detach from this buffer in case we no longer want it
				if not utils.buffer.is_valid(buf, excluded_filetypes) then
					return true
				end

				highlight.buffer(buf, first, last_new, "buf:on_lines")
			end,
			on_detach = function()
				highlight.buffers[buf] = nil
			end
		})

		local highlighter = require("vim.treesitter.highlighter").active[buf]
		if highlighter then
			-- also listen to TS changes so we can properly update the buffer based on is_comment
			highlighter.tree:register_cbs({
				on_changedtree = function(changes)
					for _, change in ipairs(changes or {}) do
						vim.defer_fn(function()
							highlight.buffer(buf, change[1], change[3] + 1, "on_changedtree")
						end, 0)
					end
				end
			})
		end

		highlight.buffers[buf] = true
		highlight.window(win)
		highlight.windows[win] = true
	elseif not highlight.windows[win] then
		highlight.window(win)
		highlight.windows[win] = true
	end
end

function highlight.stop()
	pcall(vim.cmd, "autocmd! TODO")
	pcall(vim.cmd, "augroup! TODO")

	highlight.windows = {}
	vim.fn.sign_unplace("todo-signs")
	for buf, _ in pairs(highlight.buffers) do
		if vim.fn.bufexists(buf) then
			vim.api.nvim_buf_clear_namespace(buf, config.namespace, 0, -1)
		end
	end
	highlight.buffers = {}

	highlight.enabled = false
end

function highlight.start()
	if highlight.enabled then
		highlight.stop()
	end

	-- setup auto-commands
	vim.api.nvim_exec([[
		augroup TODO
			autocmd!
			autocmd BufWinEnter,WinNew * lua require("todo-comments.highlight").attach()
			autocmd WinScrolled * lua require("todo-comments.highlight").window()
			autocmd ColorScheme * lua vim.defer_fn(require("todo-comments.config").colors, 10)
		augroup end
	]], false)

	-- attach to all buffers in visible windows
	for _, win in pairs(vim.api.nvim_list_wins()) do
		highlight.attach(win)
	end

	highlight.enabled = true
end

return highlight
