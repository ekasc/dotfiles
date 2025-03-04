local M = {
	"evanleck/vim-svelte",
	"ray-x/go.nvim",
	"ray-x/guihua.lua",
	"tpope/vim-surround",
	"junegunn/fzf",
	{
		"piersolenski/telescope-import.nvim",
		config = function()
			require("telescope").load_extension("import")
		end,
	},
	"folke/flash.nvim",
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
	},
	"RRethy/vim-illuminate",
	{
		"sphamba/smear-cursor.nvim",
		opts = {},
	},
	{
		"barrett-ruth/live-server.nvim",
		build = "pnpm add -g live-server",
		cmd = { "LiveServerStart", "LiveServerStop" },
		config = true,
	},
	{
		"danymat/neogen",
		config = true,
	},
	{
		"kdheepak/lazygit.nvim",
	},
}

return M
