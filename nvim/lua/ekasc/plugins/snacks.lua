local M = {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	--@type snacks.Config
	opts = {
		-- dashboard = { enabled = true },
		notifier = { enabled = true },
		indent = { enabled = true },
		git = { enabled = true },
		animate = { enabled = true },
		lazygit = { enabled = true },
	},
	keys = {
		{
			"<leader>x",
			function()
				Snacks.picker.smart()
			end,
			desc = "Smart Find Files",
		},
		{
			"gd",
			function()
				Snacks.picker.lsp_definitions()
			end,
			desc = "Goto Definition",
		},
		{
			"<leader>z",
			function()
				Snacks.zen()
			end,
			desc = "Toggle Zen Mode",
		},
	},
}

return M
