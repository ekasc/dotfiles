local M = {
	"carlos-algms/agentic.nvim",

	---@type agentic.PartialUserConfig
	opts = {
		provider = "opencode-acp",
		windows = {
			position = "right",
			width = "40%",
		},
	},

	keys = {
		{
			"<C-\\>",
			function()
				require("agentic").toggle()
			end,
			mode = { "n", "v", "i" },
			desc = "Toggle Agentic Chat",
		},
		{
			"<C-'>",
			function()
				require("agentic").add_selection_or_file_to_context()
			end,
			mode = { "n", "v" },
			desc = "Add file or selection to Agentic context",
		},
		{
			"<C-,>",
			function()
				require("agentic").new_session()
			end,
			mode = { "n", "v", "i" },
			desc = "New Agentic Session",
		},
	},
}

return M
