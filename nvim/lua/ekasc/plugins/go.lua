local M = {
	"ray-x/go.nvim",
	dependencies = { -- optional packages
		"ray-x/guihua.lua",
		"neovim/nvim-lspconfig",
		-- "nvim-treesitter/nvim-treesitter",
	},
	ft = { "go", "gomod" },
	build = ':lua require("go.install").update_all_sync()',
	cmd = { "GoInstallBinaries", "GoUpdateBinaries", "GoTest", "GoRun" }
}

function M.config()
	require("go").setup()
end

return M
