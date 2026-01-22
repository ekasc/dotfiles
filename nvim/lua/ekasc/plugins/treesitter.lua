return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		ensure_installed = {
			"go",
			"json",
			"tsx",
			"css",
			"html",
			"python",
			"javascript",
			"typescript",
			"lua",
			"sql",
		},
		sync_install = false,
		auto_install = false,
		indent = {
			enable = true,
		},
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
			disable = function(_, buf)
				local max_filesize = 200 * 1024
				local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
				return ok and stats and stats.size > max_filesize
			end,
		},
		autotag = {
			enable = true,
		},
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
