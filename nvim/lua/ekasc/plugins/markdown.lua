local M = {
	"OXY2DEV/markview.nvim",
	dependencies = {
		"saghen/blink.cmp",
	},
}

function M.config()
	require("markview.highlights").setup()
end

return M
