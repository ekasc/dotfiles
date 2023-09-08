local M = {
	"themaxmarchuk/tailwindcss-colors.nvim",
}

function M.config()
	require("tailwindcss-colors").setup()
end

return M
