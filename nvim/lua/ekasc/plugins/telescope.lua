local M = {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	lazy = true,
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		{ "nvim-tree/nvim-web-devicons" },
		{ "nvim-telescope/telescope-ui-select.nvim" },
	},
}

function M.config()
	local builtin = require("telescope.builtin")
	-- vim.keymap.set("n", "<leader>x", builtin.find_files, {})
	-- vim.keymap.set("n", "<C-p>", builtin.git_files, {})
	-- vim.keymap.set("n", "<leader>ps", function()
	-- 	builtin.grep_string({ search = vim.fn.input("Grep > ") })
	-- end)

	local telescope = require("telescope")
	telescope.setup({
		defaults = {
			prompt_prefix = " ",
			selection_caret = " ",
			path_display = {
				"smart",
			},
			file_ignore_patterns = {
				".git/",
				"node_modules",
				"vendor",
				"dist",
				"obj",
			},
		},
		extensions = {
			-- ["ui-select"] = {
			-- 	require("telescope.themes").get_dropdown({
			-- 		winblend = 10,
			-- 	}),
			-- },
			fzf = {
				fuzzy = true, -- false will only do exact matching
				override_generic_sorter = true, -- override the generic sorter
				override_file_sorter = true, -- override the file sorter
				case_mode = "smart_case", -- or "ignore_case" or "respect_case"
				-- the default case_mode is "smart_case"
			},
		},
	})
	telescope.load_extension("fzf")
	telescope.load_extension("ui-select")
end

return M
