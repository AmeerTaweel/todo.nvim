local treesitter = {}

-- returns nil if buf does not have a treesitter parser
function treesitter.is_comment(buf, line)
	local highlighter = require("vim.treesitter.highlighter").active[buf]

	if not highlighter then
		return
	end

	local is_comment = false

	highlighter.tree:for_each_tree(function(tree, lang_tree)
		if is_comment then
			return
		end

		local query = highlighter:get_query(lang_tree:lang())
		if not (query and query:query()) then
			return
		end

		local iter = query:query():iter_captures(tree:root(), buf, line, line + 1)

		for capture, _ in iter do
			if query._query.captures[capture] == "comment" then
				is_comment = true
			end
		end
	end)

	return is_comment
end

return treesitter
