local M = {
	'numToStr/Comment.nvim',
	dependencies = {
		'JoosepAlviste/nvim-ts-context-commentstring'
	},
	opts = {
		ignore = '^$',
	},
	event = "VeryLazy",
}

function M.config()
	require('Comment').setup({
		pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
	})
end

return M
