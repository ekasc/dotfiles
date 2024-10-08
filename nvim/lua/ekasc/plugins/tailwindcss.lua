local M = {
	"luckasRanarison/tailwind-tools.nvim",
	dependencies = {
		-- "nvim-treesitter/nvim-treesitter",
		"nvim-lua/plenary.nvim",
		"themaxmarchuk/tailwindcss-colors.nvim",
	},
}

function M.config()
	require("tailwindcss-colors").setup()
	return require("tailwind-tools").setup({})
end

return M
