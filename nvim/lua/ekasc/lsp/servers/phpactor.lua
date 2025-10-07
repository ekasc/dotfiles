local utils = require("ekasc.lsp.utils")

return {
	on_attach = utils.on_attach,
	capabilities = utils.capabilities,
	init_options = {
		["language_server_psalm.enabled"] = true, -- keep phpstan off unless you want it
	},
}
