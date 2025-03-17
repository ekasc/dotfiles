local M = {
	"folke/trouble.nvim",
	cmd = "Trouble",
	opt = {},
	keys = {
		{
			"<leader>m",
			function()
				require("trouble").toggle("diagnostics")
			end,
			desc = "Diagnostic (Trouble)",
		},
	},
}

M.config = function()
	require("trouble").setup({})
end

return M
