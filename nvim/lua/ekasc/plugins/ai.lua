local M = {
	{
		"Exafunction/codeium.nvim",
		event = "InsertEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("codeium").setup({
				-- The Codeium server can be heavy on large repos.
				-- Keep it from scanning an enormous workspace by default.
				enable_index_service = false,
				enable_local_search = false,
			})
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
