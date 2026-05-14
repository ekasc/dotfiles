local utils = require("ekasc.lsp.utils")

return {
	cmd = { "postgres-language-server", "lsp-proxy" },
	filetypes = { "sql", "pgsql", "mysql" },
	root_markers = { ".git", "package.json", "postgres-language-server.jsonc" },
	workspace_required = false,
	on_attach = utils.on_attach,
	capabilities = utils.capabilities,
}
