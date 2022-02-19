local config = require("todo.config")
local highlight = require("todo.highlight")
local utils = require("todo.utils")

local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
	utils.log.error("This plugin requires telescope.nvim.")
	return
end

local pickers = require("telescope.builtin")
local make_entry = require("telescope.make_entry")

local todo = function(opts)
	opts = opts or {}
	opts.vimgrep_arguments = { "rg" }
	vim.list_extend(opts.vimgrep_arguments, {
		"--color=never",
		"--no-heading",
		"--with-filename",
		"--line-number",
		"--column"
	})
	opts.search = config.rg_regex
	opts.prompt_title = "Find TODO"
	opts.use_regex = true

	local entry_maker = make_entry.gen_from_vimgrep(opts)
	opts.entry_maker = function(line)
		local ret = entry_maker(line)
		ret.display = function(entry)
			local display = string.format("%s:%s:%s ", entry.filename, entry.lnum, entry.col)
			local text = entry.text
			local start, finish, kw = highlight.match(text)

			local hl = {}

			if start then
				kw = config.keywords[kw] or kw
				local icon = config.options.keywords[kw].icon
				display = icon .. " " .. display
				table.insert(hl, { { 1, #icon + 1 }, "TODOFg" .. kw })
				text = vim.trim(text:sub(start))

				table.insert(hl, {
					{ #display, #display + finish - start + 2 },
					"TODOBg" .. kw,
				})
				table.insert(hl, {
					{ #display + finish - start + 1, #display + finish + 1 + #text },
					"TODOFg" .. kw,
				})
				display = display .. " " .. text
			end

			return display, hl
		end
		return ret
	end
	pickers.grep_string(opts)
end

return telescope.register_extension({ exports = { todo = todo } })
