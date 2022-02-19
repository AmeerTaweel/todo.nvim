command! -nargs=* TODOQuickfixList lua require("todo-comments.search").set_quickfix_list(<f-args>)
command! -nargs=* TODOLocationList lua require("todo-comments.search").set_location_list(<f-args>)
command! -nargs=* TODOTelescope Telescope todo-comments todo <args>
