local M = {
	"Exafunction/codeium.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
	},
}

function M.config()
	require("codeium").setup({})
	vim.g.codeium_manual = true
end

return M
