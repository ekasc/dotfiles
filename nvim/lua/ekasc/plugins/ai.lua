local M = {
	{
		"Exafunction/codeium.nvim",
		event = "InsertEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("codeium").setup({})
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		lazy = true,
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			-- require("copilot").setup({
			-- 	suggestion = {
			-- 		enabled = false,
			-- 		panel = { enabled = false },
			-- 	},
			-- })
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		lazy = true,
		config = function()
			-- require("copilot_cmp").setup()
		end,
	},
}

return M
