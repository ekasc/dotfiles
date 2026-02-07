local M = {
	{ "evanleck/vim-svelte", ft = "svelte" },
	{ "tpope/vim-surround", event = "VeryLazy" },
	{ "junegunn/fzf", cmd = "FZF" },
	"folke/flash.nvim",
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		enabled = false,
		event = { "BufReadPost", "BufNewFile" },
		---@module "ibl"
		---@type ibl.config
	},
	{ "RRethy/vim-illuminate", event = { "BufReadPost", "BufNewFile" } },
	{
		"barrett-ruth/live-server.nvim",
		build = "pnpm add -g live-server",
		cmd = { "LiveServerStart", "LiveServerStop" },
		config = true,
	},
	{
		"danymat/neogen",
		cmd = "Neogen",
		config = true,
	},
	{ "kdheepak/lazygit.nvim", cmd = "LazyGit" },
	{
		"lervag/vimtex",
		ft = "tex",
		-- tag = "v2.15", -- uncomment to pin to a specific release
		init = function()
			vim.g.vimtex_view_method = "general"
		end,
	},
	{
		"fladson/vim-kitty",
		ft = "kitty",
	},
}

return M
