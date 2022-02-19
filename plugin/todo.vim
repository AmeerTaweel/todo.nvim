command! -nargs=* TODOQuickfixList lua require("todo.search").set_quickfix_list(<f-args>)
command! -nargs=* TODOLocationList lua require("todo.search").set_location_list(<f-args>)
command! -nargs=* TODOTelescope Telescope todo todo <args>
