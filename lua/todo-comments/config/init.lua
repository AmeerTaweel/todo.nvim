local utils = require "todo-comments.utils"
local default_config = require "todo-comments.config.default"

local M = {}

M.keywords = {}
M.options = {}
M.loaded = false

M.ns = vim.api.nvim_create_namespace("todo-comments")

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, default_config, M.options or {}, opts or {})

  -- -- keywords should always be fully overriden
  if opts and opts.keywords and opts.merge_keywords == false then
    M.options.keywords = opts.keywords
  end

  for kw, kw_opts in pairs(M.options.keywords) do
    M.keywords[kw] = kw
    for _, alt in pairs(kw_opts.alt or {}) do
      M.keywords[alt] = kw
    end
  end

  local tags = table.concat(vim.tbl_keys(M.keywords), "|")
  M.search_regex = M.options.search.pattern:gsub("KEYWORDS", tags)
  M.hl_regex = {}
  local patterns = M.options.highlight.pattern
  patterns = type(patterns) == "table" and patterns or { patterns }
  for _, p in pairs(patterns) do
    p = p:gsub("KEYWORDS", tags)
    table.insert(M.hl_regex, p)
  end
  M.colors()
  M.signs()
  M.loaded = true
end

function M.signs()
  for kw, opts in pairs(M.options.keywords) do
    vim.fn.sign_define("todo-sign-" .. kw, {
      text = opts.icon,
      texthl = "TodoSign" .. kw,
    })
  end
end

function M.colors()
  local normal = utils.highlight.get("Normal", { fg = "#ffffff", bg = "#000000" })
  local fg_dark = utils.color.is_dark(normal.fg) and normal.fg or normal.bg
  local fg_light = utils.color.is_dark(normal.fg) and normal.bg or normal.fg

  local sign_hl = utils.highlight.get("SignColumn", { bg = "NONE" })

  for kw, opts in pairs(M.options.keywords) do
    local kw_color = opts.color or "default"
    local hex

    if kw_color:sub(1, 1) == "#" then
      hex = kw_color
    else
      local colors = M.options.colors[kw_color]
      colors = type(colors) == "string" and { colors } or colors

      for _, color in pairs(colors) do
        if color:sub(1, 1) == "#" then
          hex = color
          break
        end
        local c = utils.highlight.get(color)
        if c.fg then
          hex = c.fg
          break
        end
      end
    end
    if not hex then
      error("Todo: no color for " .. kw)
    end
    local fg = utils.color.is_dark(hex) and fg_light or fg_dark

    vim.cmd("hi def TodoBg" .. kw .. " guibg=" .. hex .. " guifg=" .. fg .. " gui=bold")
    vim.cmd("hi def TodoFg" .. kw .. " guibg=NONE guifg=" .. hex .. " gui=NONE")
    vim.cmd("hi def TodoSign" .. kw .. " guibg=" .. sign_hl.bg  .. " guifg=" .. hex .. " gui=NONE")
  end
end

return M
