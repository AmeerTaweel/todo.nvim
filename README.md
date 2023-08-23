# todo.nvim

**NOTE: This repository will no longer be maintained. Use [folke/todo-comments.nvim][upstream] instead.**

**todo.nvim** is a Lua plugin for Neovim to highlight and search for todo
comments like `TODO`, `FIXME`, `BUG` in your code base.

![image](https://user-images.githubusercontent.com/20538273/155287129-da8a5ded-cc4f-45be-b29f-36294fd6608b.png)

This project is forked from [folke/todo-comments.nvim][upstream].

## Features

- **Highlight** your TODO comments in different styles.
- Optionally only highlights TODOs in comments using [**TreeSitter**][treesitter].
- Configurable **signs**.
- Open TODOs in a **quickfix** list.
- Search TODOs with [Telescope][telescope].

## Requirements

- Neovim >= `0.5.0`.
- A [patched font][nerdfonts] for the icons, or change them to simple ASCII characters.
- Optional:
  - [ripgrep][ripgrep] and [plenary.nvim][plenary] are used for searching.
  - [Telescope][telescope].

## Installation

Install the plugin with your preferred package manager:

### [packer][packer]

```lua
-- Lua
use {
    "AmeerTaweel/todo.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
        require("todo").setup {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    end
}
```

### [vim-plug][plug]

```vim
" Vim Script
Plug 'nvim-lua/plenary.nvim'
Plug 'AmeerTaweel/todo.nvim'

lua << EOF
    require("todo").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    }
EOF
```

## Configuration

`todo.nvim` comes with the following defaults:

```lua
{
    signs = {
        enable = true, -- show icons in the sign column
        priority = 8
    },
    keywords = {
        FIX = {
            icon = " ", -- used for the sign, and search results
            -- can be a hex color, or a named color
            -- named colors definitions follow below
            color = "error",
            -- a set of other keywords that all map to this FIX keywords
            alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }
            -- signs = false -- configure signs for some keywords individually
        },
        TODO = { icon = " ", color = "info" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } }
    },
    merge_keywords = true, -- wheather to merge custom keywords with defaults
    highlight = {
        -- highlights before the keyword (typically comment characters)
        before = "", -- "fg", "bg", or empty
        -- highlights of the keyword
        -- wide is the same as bg, but also highlights the colon
        keyword = "wide", -- "fg", "bg", "wide", or empty
        -- highlights after the keyword (TODO text)
        after = "fg", -- "fg", "bg", or empty
        -- pattern can be a string, or a table of regexes that will be checked
        -- vim regex
        pattern = [[.*<(KEYWORDS)\s*:]],
        comments_only = true, -- highlight only inside comments using treesitter
        max_line_len = 400, -- ignore lines longer than this
        exclude = {} -- list of file types to exclude highlighting
    },
    -- list of named colors
    -- a list of hex colors or highlight groups
    -- will use the first valid one
    colors = {
        error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
        warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
        info = { "DiagnosticInfo", "#2563EB" },
        hint = { "DiagnosticHint", "#10B981" },
        default = { "Identifier", "#7C3AED" }
    },
    search = {
        -- don't replace the (KEYWORDS) placeholder
        pattern = [[\b(KEYWORDS):]] -- ripgrep regex
    }
}
```

## Usage

`todo.nvim` matches on any text that starts with one of your defined keywords
(or alternatives) followed by a colon:

- TODO: Do something.
- FIX: This should be fixed.
- WARN: Weird code warning.

TODOs are highlighted in all regular files.

Each of the commands below can have an options argument to specify the directory
to search for comments, like:

```vim
:TODOQuickfixList cwd=~/projects/foobar
```

### `:TODOQuickfixList`

This uses the quickfix list to show all TODOs in your project.

![image](https://user-images.githubusercontent.com/20538273/155287403-1b99b3ec-6464-49d0-a1d9-2bc4c7bfd473.png)

### `:TODOLocationList`

This uses the location list to show all TODOs in your project.

![image](https://user-images.githubusercontent.com/20538273/155287495-1bf313fa-fd5c-47d3-97b0-a5b9758a2a5f.png)

### `:TODOTelescope`

Search through all project TODOs with Telescope.

![image](https://user-images.githubusercontent.com/20538273/155287589-b6a3700d-b752-4e01-88db-ba3e2d8eca3c.png)

[upstream]: https://github.com/folke/todo-comments.nvim
[treesitter]: https://github.com/nvim-treesitter/nvim-treesitter
[telescope]: https://github.com/nvim-telescope/telescope.nvim
[ripgrep]: https://github.com/BurntSushi/ripgrep
[plenary]: https://github.com/nvim-lua/plenary.nvim
[nerdfonts]: https://www.nerdfonts.com
[packer]: https://github.com/wbthomason/packer.nvim
[plug]: https://github.com/junegunn/vim-plug
