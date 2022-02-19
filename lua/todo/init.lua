local config = require("todo.config")
local highlight = require("todo.highlight")

local M = {}

local options = {}

M.setup = function(opts)
	if opts then
		options = opts
	end

	-- lazy-load plugin
	if vim.api.nvim_get_vvar("vim_did_enter") == 0 then
		vim.cmd([[autocmd VimEnter * ++once lua require("todo").setup()]])
		return
	end

	config.setup(options)
	highlight.start()
end

return M
