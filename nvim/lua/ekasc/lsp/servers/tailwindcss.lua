local utils = require("ekasc.lsp.utils")
local tailwind_highlight = require("tailwind-highlight")

return {
	on_attach = function(client, bufnr)
		tailwind_highlight.setup(client, bufnr, {
			single_column = false,
			mode = "background",
			debounce = 350,
		})
		utils.on_attach(client, bufnr)
	end,
	capabilities = utils.capabilities,
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"html",
		"svelte",
		"css",
	},
	settings = {
		tailwindCSS = {
			classRegex = {
				'class="([^"]*)"',
				"class='([^']*)'",
				'className="([^"]*)"',
				"className='([^']*)'",
				"class:\\s*\"([^\"]*)\"",
				"class:\\s*'([^']*)'",
			},
			includeLanguages = {
				javascript = "javascriptreact",
				typescript = "typescriptreact",
			},
			suggestions = true,
			hover = true,
			codeActions = true,
			validate = true,
		},
	},
}
