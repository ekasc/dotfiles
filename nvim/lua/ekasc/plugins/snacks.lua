local M = {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,

	---@type snacks.Config
	opts = {
		explorer = {
			enabled = true,
			-- Avoid BufEnter hooks that replace netrw (can cause redraw loops on special buffers).
			replace_netrw = false,
		},
		dashboard = { enabled = false, example = "startify" },
		notifier = { enabled = true },
		indent = { enabled = true },
		-- disable images (extra WinScrolled work)
		image = { enabled = false },
		git = { enabled = true },
		-- Smooth-scrolling + heavy WinScrolled handlers can peg CPU on some setups.
		-- Keep only the window animations you explicitly use.
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
		scroll = { enabled = false },
		lazygit = { enabled = true },
		-- statuscolumn = { enabled = true },
		picker = { enabled = true },
	},
	keys = {
		{
			"<leader>i",
			function()
				Snacks.picker.highlights()
			end,
			desc = "Highlights",
		},

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
			"<C-b>",
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
