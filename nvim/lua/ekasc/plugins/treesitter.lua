return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		-- A list of parser names, or "all"
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

		-- Install parsers synchronously (only applied to `ensure_installed`)
		sync_install = false,

		-- Automatically install missing parsers when entering buffer
		-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
		auto_install = true,

		indent = {
			enable = true,
			disable = {},
		},

		highlight = {
			-- `false` will disable the whole extension
			enable = true,

			-- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
			-- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
			-- the name of the parser)
			-- list of language that will be disabled
			additional_vim_regex_highlighting = false,
		},
		rainbow = {
			enable = true,
			query = "rainbow-parens",
			disable = { "jsx", "tsx", "html" }
		},
		autotag = {
			enable = true,
		},

	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
