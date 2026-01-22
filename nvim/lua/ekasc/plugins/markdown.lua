local M = {
	"OXY2DEV/markview.nvim",
}

function M.config()
	require("markview.highlights").setup()
end

return M
