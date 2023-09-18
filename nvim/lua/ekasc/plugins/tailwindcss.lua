local M = {
	"laytan/tailwind-sorter.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-lua/plenary.nvim",
		"themaxmarchuk/tailwindcss-colors.nvim",
	},
	build = "cd formatter && npm i && npm run build",
}

function M.config()
	require("tailwindcss-colors").setup()
	require("tailwind-sorter").setup()
end

return M
