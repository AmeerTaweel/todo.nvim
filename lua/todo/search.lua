local config = require "todo.config"
local highlight = require "todo.highlight"
local utils = require "todo.utils"

local M = {}

function M.to_list_items(lines)
	local items = {}
	for _, line in pairs(lines) do
		local file, row, col, text = line:match("^(.+):(%d+):(%d+):(.*)$")
		if file then
			local item = {
				filename = file,
				lnum = tonumber(row),
				col = tonumber(col),
				line = text,
			}

			local start, finish, kw = highlight.match(text)

			if start then
				kw = config.keywords[kw] or kw
				item.tag = kw
				item.text = vim.trim(text:sub(start))
				item.message = vim.trim(text:sub(finish + 1))
				table.insert(items, item)
			end
		end
	end
	return items
end

function M.search(callback, opts)
	opts = opts or {}
	opts.cwd = opts.cwd or "."
	opts.cwd = vim.fn.fnamemodify(opts.cwd, ":p")
	opts.disable_not_found_warnings = opts.disable_not_found_warnings or false
	if not config.is_loaded then
		utils.log.error("Plugin is not loaded. Did you run setup()?")
		return
	end

	local command = "rg"

	if vim.fn.executable(command) ~= 1 then
		utils.log.error(command .. " was not found in your path.")
		return
	end

	local found, job = pcall(require, "plenary.job")
	if not found then
		utils.log.error("Search requires plenary.nvim.")
		return
	end

	local args = vim.tbl_flatten({{
		"--color=never",
		"--no-heading",
		"--with-filename",
		"--line-number",
		"--column"
	}, config.rg_regex, opts.cwd })

	job:new({
		command = command,
		args = args,
		on_exit = vim.schedule_wrap(function(search, code)
			if code == 2 then
				local error = table.concat(search:stderr_result(), "\n")
				utils.log.error(command .. " failed with code " .. code .. ".\n" .. error)
			end
			if code == 1 and opts.disable_not_found_warnings ~= true then
				utils.log.warn("No TODOs found.")
			end
			local lines = search:result()
			callback(M.to_list_items(lines))
		end)
	}):start()
end

function M.set_list(opts, use_location_list)
	if type(opts) == "string" then
		opts = { cwd = opts }
		if opts.cwd:sub(1, 4) == "cwd=" then
			opts.cwd = opts.cwd:sub(5)
		end
	end
	opts = opts or {}
	opts.open = (opts.open ~= nil) and opts.open or true

	M.search(function(items)
		if #items == 0 then
			return
		end

		if use_location_list then
			vim.fn.setloclist(0, {}, " ", { title = "TODO", id = "$", items = items })
		else
			vim.fn.setqflist({}, " ", { title = "TODO", id = "$", items = items })
		end

		if opts.open then
			vim.cmd(use_location_list and "lopen" or "copen")
		end

		local win = vim.fn.getqflist({ winid = true })
		if win.winid ~= 0 then
			highlight.window(win.winid, true)
		end
	end, opts)
end

function M.set_quickfix_list(opts)
	M.set_list(opts)
end

function M.set_location_list(opts)
	M.set_list(opts, true)
end

return M
