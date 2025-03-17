local M = {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,

	---@type snacks.Config
	opts = {
		explorer = { enabled = true, replace_netrw = true },
		dashboard = { enabled = true, example = "startify" },
		notifier = { enabled = true },
		indent = { enabled = true },
		git = { enabled = true },
		animate = {
			enabled = true,
			style = {
				width = 0.6,
				height = 0.6,
				border = "rounded",
				title = " Git Blame ",
				title_pos = "center",
				ft = "git",
			},
		},
		lazygit = { enabled = true },
		-- statuscolumn = { enabled = true },
		picker = { enabled = true },
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
			"<leader>z",
			function()
				Snacks.zen()
			end,
			desc = "Toggle Zen Mode",
		},
		{
			"<leader>ps",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>,",
			function()
				Snacks.picker.explorer()
			end,
			desc = "File Explorer",
		},
		{
			"<C-p>",
			function()
				Snacks.picker.git_files()
			end,
			desc = "Find Git Files",
		},
		{
			"<C-a>",
			function()
				Snacks.picker.commands()
			end,
			desc = "Commands",
		},
		{
			"<leader>k",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "Keymaps",
		},
		{
			"<c-g>",
			function()
				Snacks.picker.diagnostics_buffer()
			end,
		},
	},
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				-- Create some toggle mappings
				Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
			end,
		})
	end,
}

return M
