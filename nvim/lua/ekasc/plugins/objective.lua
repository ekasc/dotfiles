local M = {
	"ekasc/objective.nvim",
	-- dir = "~/Projects/lua/objective.nvim",
	-- name = "objective.nvim",
	dependencies = { "MunifTanjim/nui.nvim" },
	event = { "BufReadPost", "BufNewFile" },
}

function M.config()
	require("objective").setup({
		mapping = "<leader>or",
	})
end

return M
