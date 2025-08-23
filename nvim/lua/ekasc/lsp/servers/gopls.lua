local utils = require("ekasc.lsp.utils")

return {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork" },
	root_dir = vim.fs.root(0, { "go.mod", ".git" }),
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
				nilness = true,
				unusedwrite = true,
			},
			staticcheck = true,
		},
	},
	on_attach = utils.on_attach,
	capabilities = utils.capabilities,
}
